import numpy as np
import pandas as pd
import sys

from trachoma.trachoma_simulations import Trachoma_Simulation

argn = len(sys.argv)

BetFilePath = str(sys.argv[1])
MDAFilePath = str(sys.argv[2])
PrevFilePath = str(sys.argv[3])
InfectFilePath = str(sys.argv[4])
OutSimFilePath = str(sys.argv[5])

Trachoma_Simulation(BetFilePath=BetFilePath,
                    MDAFilePath=MDAFilePath,
                    PrevFilePath=PrevFilePath,
                    InfectFilePath=InfectFilePath,
                    SaveOutput=True,
                    OutSimFilePath=OutSimFilePath,
                    InSimFilePath=None)
