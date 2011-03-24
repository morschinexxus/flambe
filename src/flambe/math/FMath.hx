package flambe.math;

class FMath
{
    // All the constants from Math, but inlinable at compile-time
    public static inline var E = 2.718281828459045;
    public static inline var LN2 = 0.6931471805599453;
    public static inline var LN10 = 2.302585092994046;
    public static inline var LOG2E = 1.4426950408889634;
    public static inline var LOG10E = 0.43429448190325176;
    public static inline var PI = 3.141592653589793;
    public static inline var SQRT1_2 = 0.7071067811865476;
    public static inline var SQRT2 = 1.4142135623730951;

    inline public static function toInt (f :Float) :Int
    {
#if (js || flash)
        return (cast f) | 0;
#else
        return Std.int(f);
#end
    }

    inline public static function toRadians (degrees :Float) :Float
    {
    	return degrees * PI/180;
    }

    inline public static function toDegrees (radians :Float) :Float
    {
    	return radians * 180/PI;
    }
}
