using SDL2;
using System;
using System.Collections;
using System.Diagnostics;

namespace FlappyCow
{
	class PipeManager
	{
		static Random Rng = new Random(Stopwatch.GetTimestamp()) ~ delete _;
		public List<Pipe> Pipes = new List<Pipe>() ~ delete _;
		public Stopwatch GracePeriodTimer = new Stopwatch() ~ delete _;

		const float HorizontalDistanceBetweenPipes = 280;
		const float VerticalDistanceBetweenPipes = 175;
		const float MinY = 100; // Needs to be at least as big as pipe-top.png is tall.
		const float MaxY = Background.FloorY - MinY - VerticalDistanceBetweenPipes;
		const double GracePeriod = 0.5;

		public int Update(Cow cow)
		{
			if (!GracePeriodTimer.IsRunning)
				GracePeriodTimer.Start();

			int crossed = 0;

			if (GracePeriodTimer.ElapsedSeconds > GracePeriod)
			{
				float cowX = cow.Center.x - Pipe.Width / 2;
				for (int i = 0; i < Pipes.Count; ++i)
				{
					float oldX = Pipes[i].X;
					Pipes[i].Update();
					float newX = Pipes[i].X;
					if (oldX >= cowX && newX < cowX)
						++crossed;
				}

				Pipes.RemoveAll(scope (p) => p.X + Pipe.Width < 0);

				if (Pipes.IsEmpty)
					AddNewPipe();

				float right = Pipes.Back.X + Pipe.Width;
				if (Game.Width - right > HorizontalDistanceBetweenPipes)
					AddNewPipe();
			}

			return crossed;
		}

		public void Draw(SDL.Renderer* renderer)
		{
			for (int i = 0; i < Pipes.Count; ++i)
				Pipes[i].Draw(renderer);
		}

		void AddNewPipe()
		{
			float y = MinY + (float)Rng.NextDouble() * (MaxY - MinY);
			Pipe pipe = .{ X = Game.Width, TopY = y, BottomY = y + VerticalDistanceBetweenPipes };
			Pipes.Add(pipe);
		}
	}
}
