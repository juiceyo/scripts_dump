## Stops you from going afk in the software of your choice. Exit by pressing ESC - some games will not allow this script.

import pyautogui as pag
import time
import random
import keyboard

running = True

def stop_script():
    global running
    running = False
    print("Script stopped.")
    
keyboard.add_hotkey('esc', stop_script)

while running:
        x = random.randint(0, pag.size().width)
        y = random.randint(0, pag.size().height)
        pag.moveTo(x, y, duration=0.5)
        time.sleep(random.uniform(5, 15))

keyboard.unhook_all()