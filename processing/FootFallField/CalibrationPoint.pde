
// A pair of foot position and screen position used during calibration
public class CalibrationPoint
  {
    Reading foot;
    PVector screenPos;
    
    public CalibrationPoint( Reading _foot, PVector _screenPos )
    {
      foot = _foot;
      screenPos = _screenPos;
    }
  }