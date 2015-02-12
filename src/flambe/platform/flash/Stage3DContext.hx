package flambe.platform.flash;

import flash.display3D.Context3D;
import flash.geom.Rectangle;

class Stage3DContext
{
    public var context3D(default, null):Context3D;

    public var shared(default, null):Bool;
   public var viewport(default, default):Rectangle;

    public function new(context3D:Context3D, ?shared = false)
    {
      this.context3D = context3D;
      this.shared = shared;
    }
}