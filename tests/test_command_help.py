from dali_poo.bot import command_help


respond_args = None
ack_called = False


def respond(*args, **kwargs):
    global respond_args
    respond_args = (args, kwargs)


def ack(*args, **kwargs):
    global ack_called
    ack_called = True


def test_command_help():
    """
    tests the command_help function
    """
    command_help(respond=respond, ack=ack)

    assert ack_called

    args, kwargs = respond_args
    expect = "Please add the commands available."
    assert args and expect == args[0].strip()