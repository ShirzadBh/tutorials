import os
import MaxPlus
from PySide2 import QtCore, QtGui
from PySide2 import QtWidgets
from PySide2.QtWidgets import QVBoxLayout, QPushButton, QDialog, QWidget
from pymxs import runtime as mxs


class ExtendDirection(QDialog):
    def __init__(self, parent=MaxPlus.GetQMaxMainWindow()):
        super(ExtendDirection, self).__init__(parent)
        self.init()
        self.start()
        self.addElements()
        
    def start(self):
        try:
            mxs.unregisterRedrawViewsCallback(self.debugView)
        except:
            pass
            
    def addElements(self):
        self.close_btn = QPushButton("Done!")
        self.pick_points_btn = QPushButton("Pick Points")
        self.layout.addWidget(self.pick_points_btn)
        self.layout.addWidget(self.close_btn)
        self.pick_points_btn.clicked.connect(self.pickPoints)
        self.close_btn.clicked.connect(self.closeWindow)

    def init(self):
        self.layout = QVBoxLayout()
        self.layout.setMargin(4)
        self.setLayout(self.layout)
        self.resize(160, 10)
        self.setWindowTitle("Extend Direction")
        self.setWindowFlags(self.windowFlags() ^ QtCore.Qt.WindowContextHelpButtonHint) 


    def pickPoints(self):
        self.geo = self.geometry()        
        self.hide()
        
        try:
            mxs.unregisterRedrawViewsCallback(self.debugView)
        except:
            pass
                
        try:
            self.pos1 = mxs.pickPoint(snap=mxs.readvalue(mxs.StringStream('#3D')))
            self.pos2 = mxs.pickPoint(snap=mxs.readvalue(mxs.StringStream('#3D')))

            self.moveVector = self.pos2 - self.pos1
            
            vector = self.moveVector

            X = mxs.normalize(vector)
            Z = mxs.point3(0, 0, 1)
            Y = mxs.normalize(mxs.cross(Z, X))
            Z = mxs.normalize(mxs.cross(X, Y))

            self.transform = mxs.matrix3(Z, Y, X, mxs.point3(0, 0, 0))
            
            mxs.WorkingPivot.SetTM(self.transform)
            mxs.execute("max tti")
            
            mxs.registerRedrawViewsCallback(self.debugView)
            mxs.execute("max move")
            mxs.execute("toolMode.coordsys #working_pivot")
            self.show()
            self.setGeometry(self.geo)
            
        except:
            print("Point Picking Cancelled")
            
    def debugView(self):
        mxs.gw.Marker(self.pos1, mxs.readvalue(mxs.StringStream('#circle')), color=mxs.red)
        mxs.gw.Marker(self.pos2, mxs.readvalue(mxs.StringStream('#circle')), color=mxs.red)
        mxs.gw.Polyline((self.pos1, self.pos2), False)
        mxs.gw.enlargeUpdateRect(mxs.readvalue(mxs.StringStream('#whole')))
        mxs.gw.updateScreen()
    
    def closeWindow(self):
        self.close()
        
    def closeEvent(self, event):
        mxs.WorkingPivot.SetTM(mxs.matrix3(1))

        try:
            mxs.unregisterRedrawViewsCallback(self.debugView)
        except:
            pass
        mxs.redrawViews()
        
def main():
    dlg = ExtendDirection()
    dlg.show()


if __name__ == '__main__':
    main()
