import tkinter as tk 
import sys
import collections

class UI(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.grid()
        self.labels = collections.OrderedDict()
        self.entries = collections.OrderedDict() 
        self.buttons = collections.OrderedDict()
    
    def add_label(self, text, row=0, column=0, fg="black"):
        self.labels[text + "_label"] = tk.Label(self, text=text, fg=fg)
        self.labels.get(text + "_label").grid(row=row, column=column)
    
    def add_entry(self, name, row=0, column=0, width=20, fg="black"):
        self.entries[name] = tk.Entry(self, width=width)
        self.entries.get(name).grid(row=row, column=column)

    def add_button(self, text, row=0, column=0, cmd=lambda: None, fg="black"):
        def pressed():
            self.buttons.get(text + "_button").configure(bg="red")
            cmd()
        self.buttons[text + "_button"] = tk.Button(self, text=text, fg=fg, 
                        command=pressed)
        self.buttons.get(text + "_button").grid(row=row, column=column)
    
    def exit(self):
        self.master.destroy()


def create_main_interface(master):
    ui = UI(master)
    ui.add_button("Add subnet", 0, 0, 
        create_new_independent_interface(master, ui, create_add_subnet_interface))
    ui.add_button("Add host", 0, 1, 
        create_new_independent_interface(master, ui, create_add_host_interface))
    ui.add_button("Quit", 1, 2, ui.exit)
    return ui


def create_add_host_interface(master):
    ui = UI(master)

    ui.add_label("hostname", 0, 0)
    ui.add_label("dhcp-client-identifier/switch-identifier", 1, 0)
    ui.add_label("router_ip", 2, 0)
    ui.add_label("fixed_ip", 3, 0)
    ui.add_label("tftp_server_address", 4, 0)
    ui.add_label("bootfile_name", 5, 0)

    ui.add_entry("hostname", 0, 1)
    ui.add_entry("dhcp-client-identifier/switch-identifier", 1, 1)
    ui.add_entry("router_ip", 2, 1)
    ui.add_entry("fixed_ip", 3, 1)
    ui.add_entry("tftp_server_address", 4, 1)
    ui.add_entry("bootfile_name", 5, 1)

    ui.add_button("Confirm", 6, 2)
    ui.add_button("Clear", 6, 3, lambda: clear_all_entries(ui))
    ui.add_button("Back to Main", 6, 4, 
        create_new_independent_interface(master, ui, lambda: create_main_interface(ui)))
    ui.add_button("Quit", 6, 5, ui.exit)
    
    return ui


def create_add_subnet_interface(master):
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

    ui.add_button("Confirm", 8, 2)
    ui.add_button("Clear", 8, 3, clear_all_entries)
    ui.add_button("Back to Main", 8, 4, 
        create_new_independent_interface(master, ui, create_main_interface))
    ui.add_button("Quit", 8, 5, ui.exit)
    
    return ui


def create_new_independent_interface(master, current_int,func):
    def helper():
        func(master)
        current_int.destroy()
    return helper


def clear_all_entries(ui):
    for key in ui.entries.keys():
        e = ui.entries[key]
        e.delete(0, len(e.get()))


UIroot = tk.Tk()
ui = create_main_interface(UIroot)
ui.mainloop()
