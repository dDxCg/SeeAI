import sys
if sys.version_info[0:2] != (3, 12):
    raise Exception('Requires python 3.12')

import kivy
from kivy.app import App
from kivy.uix.label import Label

class MainApp(App):
    def build(self):
        return Label(text="Demo")
    
if __name__ == '__main__':
    MainApp().run()