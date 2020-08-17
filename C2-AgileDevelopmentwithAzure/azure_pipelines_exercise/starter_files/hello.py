import click

@click.command(help="This is just a hello app. It does nothing.")
@click.option("--name", prompt="I need your name", help="Need name")
@click.option("--color", prompt="I need your color", help="This is your color")
def hello(name, color):
    if name == "Thor":
        click.echo("Thor, you are always red.")
        click.echo(click.style(f"Hello {name}!", fg="red"))
    else:
        click.echo(f"Your color is {color}!")
        click.echo(click.style(f"Hello {name}!", fg=color))

if __name__ == "__main__":
    hello()
