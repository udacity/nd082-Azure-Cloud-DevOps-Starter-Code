from click.testing import CliRunner
from hello import hello

def test_hello():
    runner = CliRunner()
    result = runner.invoke(hello, ["--name", "Thor",
        "--color", "blue"])
    assert "Thor" in result.output
