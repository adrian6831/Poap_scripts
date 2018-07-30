import os
import sys
import tkinter as tk
import collections
import fileinput

class UI(tk.Frame):
    """
    Class defining a user interface. An instance of this class
    represents an input interface.
    """
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.grid()
        self.labels = collections.OrderedDict()
        self.entries = collections.OrderedDict() 
        self.buttons = collections.OrderedDict()
    
    def add_label(self, text, row=0, column=0, fg="black"):
        """
        Add a label to the interface.
        
        Parameters:
            text: text shown on the label
            row: row number, used as coordinate (labels with row=1 will be above labels with row=2)
            column: column number, used as coordinate
            fg: color of the text
        """
        self.labels[text + "_label"] = tk.Label(self, text=text, fg=fg)
        self.labels.get(text + "_label").grid(row=row, column=column)
    
    def add_entry(self, name, row=0, column=0, width=20, fg="black"):
        """
        Add an entry for input to the interface
        Parameters:
            name: name of the entry used by entry dict as a key, must be unique
            row: row number, used as coordinate (labels with row=1 will be above labels with row=2)
            column: column number, used as coordinate
            width: width of the entry
            fg: color of the text
        """
        self.entries[name] = tk.Entry(self, width=width)
        self.entries.get(name).grid(row=row, column=column)

    def add_button(self, text, row=0, column=0, cmd=lambda: None, fg="black"):
        """
        Add a button to the interface.
        
        Parameters:
            text: text shown on the button
            row: row number, used as coordinate (labels with row=1 will be above labels with row=2)
            column: column number, used as coordinate
            cmd: function executed after the button is clicked
            fg: color of the text
        """
        def pressed():
            self.buttons.get(text + "_button").configure(bg="red")
            cmd()
        self.buttons[text + "_button"] = tk.Button(self, text=text, fg=fg, 
                        command=pressed)
        self.buttons.get(text + "_button").grid(row=row, column=column)
    
    def exit(self):
        self.master.destroy()


def create_main_interface(master):
    """
    Create the "master" interface. On this interface, users may choose to go to 
    add_host interface or add_subnet interface.
    """
    ui = UI(master)
    ui.add_button("Add subnet", 0, 0, 
        create_new_independent_interface(master, ui, create_add_subnet_interface))
    ui.add_button("Add host", 0, 1, 
        create_new_independent_interface(master, ui, create_add_host_interface))
    ui.add_button("Quit", 1, 2, ui.exit)
    return ui


def create_add_host_interface(master):
    """
    Create an add_host interface. Input on this interface will be used to create
    a host block with poap function on dhcpd.conf. 
    """
    ui = UI(master)

    ui.add_label("hostname", 0, 0)
    ui.add_label("dhcp-client-identifier/switch-identifier", 1, 0)
    ui.add_label("router_ip", 2, 0)
    ui.add_label("fixed_ip", 3, 0)
    ui.add_label("tftp_server_address", 4, 0)
    ui.add_label("bootfile", 5, 0)

    ui.add_entry("hostname", 0, 1)
    ui.add_entry("dhcp-client-identifier/switch-identifier", 1, 1)
    ui.add_entry("router_ip", 2, 1)
    ui.add_entry("fixed_ip", 3, 1)
    ui.add_entry("tftp_server_address", 4, 1)
    ui.add_entry("bootfile", 5, 1)

    ui.add_button("Confirm", 6, 2, lambda: add_host(ui.entries))
    ui.add_button("Clear", 6, 3, lambda: clear_all_entries(ui))
    ui.add_button("Back to Main", 6, 4, 
        create_new_independent_interface(master, ui, lambda: create_main_interface(ui)))
    ui.add_button("Quit", 6, 5, ui.exit)
    
    return ui


def create_add_subnet_interface(master):
    """
    Create an add_subnet interface. Input on this interface will be used to create
    a subnet block with poap function on dhcpd.conf. 
    """
    ui = UI(master)

    ui.add_label("network_address", 0, 0)
    ui.add_label("netmask", 1, 0)
    ui.add_label("range_start", 2, 0)
    ui.add_label("range_end", 3, 0)
    ui.add_label("broadcast_address", 4, 0)
    ui.add_label("router_address", 5, 0)
    ui.add_label("tftp_server_address", 6, 0)
    ui.add_label("bootfile", 7, 0)

    ui.add_entry("network_address", 0, 1)
    ui.add_entry("netmask", 1, 1)
    ui.add_entry("range_start", 2, 1)
    ui.add_entry("range_end", 3, 1)
    ui.add_entry("broadcast_address", 4, 1)
    ui.add_entry("router_address", 5, 1)
    ui.add_entry("tftp_server_address", 6, 1)
    ui.add_entry("bootfile", 7, 1)

    ui.add_button("Confirm", 8, 2, lambda: add_subnet(ui.entries))
    ui.add_button("Clear", 8, 3, lambda: clear_all_entries(ui))
    ui.add_button("Back to Main", 8, 4, 
        create_new_independent_interface(master, ui, create_main_interface))
    ui.add_button("Quit", 8, 5, ui.exit)
    
    return ui


def create_new_independent_interface(master, current_int, func):
    """
    Return a helper function switching to a new interface by destorying current 
    interface and then create a new one with input function.

    Parameters:
        master: master of the new interface
        current_int: current interface, will be closed by the helper function returned
        func: function executed on master to create a new interface, can be create_add_subnet_interface,
              create_add_host_interface, or create_main_interface
    """
    def helper():
        func(master)
        current_int.destroy()
    return helper


def clear_all_entries(ui):
    """
    Clear contents of all entries on current interface.
    """
    for key in ui.entries.keys():
        e = ui.entries[key]
        e.delete(0, len(e.get()))

def add_host(entries):
    """
    Execute script DHCP_add_host.sh with contents of entries as parameters.

    Parameters:
        entries: a dictionary whose contents are parameters
    """
    args = entries_parser(entries)
    execute_sys_cmd(args, "../DHCP_add_host.sh", True) #please specify the path to DHCP_add_host.sh here

def add_subnet(entries):
    """
    Execute script DHCP_add_subnet.sh with contents of entries as parameters.

    Parameters:
        entries: a dictionary whose contents are parameters
    """
    args = entries_parser(entries)
    execute_sys_cmd(args, "../DHCP_add_subnet.sh", True)   #please specify the path to DHCP_add_subnet.sh here

def entries_parser(entries):
    """
    Parsing entries in a dictonary to a list and modify contents s.t. the scripts can recognize 
    those parameters when the list is converted to a string and passe to DHCP_add_host/subnet.sh.
    """
    ret = []
    for key in entries.keys():
        if entries[key].get():
            if key == "router_address" or key == "router_ip":
                ret.append("-r " + entries.get(key).get())
            elif key == "tftp_server_address":
                ret.append("-tftp " + entries.get(key).get())
            elif key == "bootfile":
                ret.append("-boot " + entries.get(key).get())
            elif key == "fixed_ip":
                ret.append("-ip " + entries.get(key).get())
            else:
                ret.append(entries[key].get())
    return ret


def execute_sys_cmd(args, cmd, is_script = False):
    """
    This script execute a system command or a script with list args
    as parameters.
    
    The parameters are as follows:
        args: arguments, a list
        cmd: a system command or full path to a script, a string
        is_script: if set true, cmd should be full path to a script
    """
    if is_script:
        script_name = cmd
        if os.access(script_name, os.X_OK):
            script_name += args_to_string(args)
            os.system(script_name)
        else:
            print("Script %s cannot be run with current\
                privilage level. Try re-run this script as root."\
                % script_name)
    else:
        cmd += args_to_string(args)
        os.system(cmd)


def args_to_string(args):
    """
    Converting args from list to string.
    """    
    args_as_str = ""
    for arg in args:
        args_as_str += " %s" % arg 
    return args_as_str


def main():
    execute_sys_cmd([], "./DHCP_init.sh", True)
    UIroot = tk.Tk()
    ui = create_main_interface(UIroot)
    ui.mainloop()

main()