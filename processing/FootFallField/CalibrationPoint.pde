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