import json
import tempfile
import unittest
from pathlib import Path
from scripts.simulador_offline import simulate
from scripts.dvwa_lab import run, classify, read_candidates, TARGET

class FakeResponse:
    status = 200
    def __init__(self, body):
        self.body = body
    def geturl(self):
        return TARGET
    def read(self, limit):
        return self.body.encode()[:limit]
    def __enter__(self):
        return self
    def __exit__(self, *args):
        return False

class FakeOpener:
    def __init__(self, bodies):
        self.bodies = iter(bodies)
        self.calls = 0
    def open(self, request, timeout):
        self.calls += 1
        return FakeResponse(next(self.bodies))

class LabTests(unittest.TestCase):
    def test_dictionary_and_spray_are_offline_and_have_distinct_order(self):
        a, b = simulate("dictionary"), simulate("spray")
        self.assertEqual(a["network_requests"], 0)
        self.assertEqual(a["authenticated"], ["ana", "bruno"])
        self.assertEqual(a["attempts"], 5)
        self.assertEqual(b["authenticated"], ["ana", "bruno"])
        self.assertNotEqual([e["user"] for e in a["events"]], [e["user"] for e in b["events"]])

    def test_lockout_can_block_later_correct_password(self):
        result = simulate("dictionary", 2)
        self.assertEqual(result["authenticated"], ["ana"])
        self.assertEqual(result["blocked"], ["bruno"])
        self.assertEqual(result["attempts"], 4)

    def test_simulation_rejects_invalid_options(self):
        with self.assertRaises(ValueError):
            simulate("invalid")
        with self.assertRaises(ValueError):
            simulate("spray", 0)

    def test_dry_run_never_calls_transport(self):
        opener = FakeOpener([])
        result = run(["wrong", "password"], opener=opener)
        self.assertEqual(result["kind"], "dry_run")
        self.assertEqual(result["network_requests"], 0)
        self.assertEqual(opener.calls, 0)

    def test_wordlist_deduplicates_and_enforces_limit(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "list.txt"
            path.write_text("one\none\n\ntwo\n")
            self.assertEqual(read_candidates(path), ["one", "two"])
            path.write_text("\n".join(str(i) for i in range(6)))
            with self.assertRaises(ValueError):
                read_candidates(path)

    def test_response_markers_not_http_status_determine_result(self):
        self.assertEqual(classify("Welcome to the password protected area admin"), "success")
        self.assertEqual(classify("Username and/or password incorrect."), "failure")
        self.assertEqual(classify("<h1>Login</h1>"), "inconclusive")
        self.assertEqual(classify("user_token"), "unexpected_token")
        self.assertEqual(classify("Welcome to the password protected area Username and/or password incorrect."), "inconclusive")

    def test_mocked_run_stops_after_success_and_does_not_log_secrets(self):
        opener = FakeOpener(["Username and/or password incorrect.", "Welcome to the password protected area admin"])
        result = run(["wrong-secret", "correct-secret", "unused"], execute=True,
                     cookie="PHPSESSID=fakesession; security=low", opener=opener, delay=lambda _: None)
        self.assertEqual(opener.calls, 2)
        self.assertEqual(result["results"][-1]["result"], "success")
        self.assertNotIn("correct-secret", json.dumps(result))
        self.assertNotIn("fakesession", json.dumps(result))

    def test_execution_requires_session_and_low_level(self):
        for cookie in ["", "PHPSESSID=x; security=high", "security=low"]:
            with self.assertRaises(ValueError):
                run(["x"], execute=True, cookie=cookie)

    def test_ambiguous_response_stops_instead_of_trying_every_password(self):
        opener = FakeOpener(["<h1>Login</h1>"])
        result = run(["x", "y"], execute=True, cookie="PHPSESSID=x; security=low", opener=opener)
        self.assertEqual(opener.calls, 1)
        self.assertEqual(result["results"][0]["result"], "inconclusive")

    def test_limit_and_username_are_checked_before_network(self):
        with self.assertRaises(ValueError):
            run(["x"] * 6)
        with self.assertRaises(ValueError):
            run(["x"], username="<script>")

if __name__ == "__main__":
    unittest.main()
