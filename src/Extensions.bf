using System;
using System.Diagnostics;

namespace FlappyCow
{
	static
	{
		public static float NextFloat(this Random r, float min, float max)
		{
			return min + (float)r.NextDouble() * (max - min);
		}

		public static void NextPointInCircle(this Random r, float centerX, float centerY, float radius, out float x, out float y)
		{
			repeat
			{
				x = (.)r.NextDoubleSigned();
				y = (.)r.NextDoubleSigned();
			} while (x*x + y*y > 1);

			x = x * radius + centerX;
			y = y * radius + centerY;
		}
	}
}

namespace System.Diagnostics
{
	extension Stopwatch
	{
		public double ElapsedSeconds { get => ElapsedMicroseconds * 1e-6; }
	}
}