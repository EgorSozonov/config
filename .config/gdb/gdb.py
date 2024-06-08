import gdb

class GetBpSourceCommand(gdb.Command):
    def __init__(self):
        gdb.Command.__init__(self, "g", gdb.COMMAND_USER)

    def getBpSource(self):
        mainPc = gdb.selected_frame().pc()
        for bp in gdb.breakpoints():
            for loc in bp.locations:
                if loc.address == mainPc:
                    return loc.source
        return None

    def invoke(self, arg, fromTty):
        bpSource = self.getBpSource()
        if bpSource is None
            return
        tmuxCommand = ("tmux send-keys -t 0 ':lua goto(\""
            + bpSource[0] + "\", " + str(bpSource[1]) + ")' Enter")
        gdb.execute("shell " + tmuxCommand)
        gdb.execute("shell tmux selectp -L")

GetBpSourceCommand()
