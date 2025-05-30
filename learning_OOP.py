from os import uname, getlogin
from psutil import virtual_memory

class PCMemory:
    def __init__(self, pc_id, user_name, memory_total, memory_used, memory_percent = None):
        self.pc_id =  pc_id
        self.user_name = user_name
        self.memory_total = memory_total
        self.memory_used = memory_used
        self.memory_percent = memory_percent
        if memory_percent == None:
            self.memory_percent = (memory_used / memory_total) * 100

        
    def show_used_percent(self):
        print(f"PC with id '{self.pc_id}' used '{self.memory_percent:.1f}' percent of memory")

    def is_enough_memory(self):
        free_memory_in_per = 100 - self.memory_percent
        free_memory_in_gb = (self.memory_total - self.memory_used) / (1024**3)
        return free_memory_in_per <= 10 or free_memory_in_gb <= 1


pc_info = PCMemory(
    pc_id = uname()[1],
    user_name = getlogin(),
    memory_total = virtual_memory().total,
    memory_used = virtual_memory().used,
    #memory_percent = virtual_memory().percent
)

pc_info.show_used_percent()
print(pc_info.is_enough_memory())


