using SDL2;
using System;
using System.Collections;
using System.Diagnostics;

namespace FlappyCow
{
	class Cow
	{
		public const float X = 140;
		public float Y;
		public float VelocityY = 0;
		public float Width => Texture.CowAnimation[0].Width;
		public float Height => Texture.CowAnimation[0].Height;
		public Stopwatch WarmupAnimationTime = Stopwatch.StartNew() ~ delete _;
		public bool IsAlive = true;
		public List<Beef> Beef = new .() ~ delete _;
		public Random Rng = new .() ~ delete _;

		const float MaxVelocity = 12;
		const float JumpAcceleration = -24;
		const float Gravity = 0.7f;

		Stopwatch AnimationTime = Stopwatch.StartNew() ~ delete _;
		float AnimationTimeAccumulator = 0;
		int Frame = 0;
		const float SecondsPerFrame = 0.1f;

		public SDL.Rect CollisionRect
		{
			get => .{
				x = (.)X + 54,
				y = (.)Y + 39,
				w = 76,
				h = 45
			};
		}
		public SDL.Point Center
		{
			get
			{
				var rect = CollisionRect;
				return .(rect.x + rect.w / 2, rect.y + rect.h / 2);
			}
		}

		public this()
		{
			Y = (Game.Height - Texture.Floor.Height) / 2.0f;
		}

		public void Update(List<Pipe> pipes, bool isWarmup)
		{
			if (isWarmup)
			{
				float t = (.)WarmupAnimationTime.ElapsedSeconds;
				Y = (Game.Height - Texture.Floor.Height) / 2.0f + 20 * Math.Sin(5*t);
			}
			else
			{
				if (Y + Height <= Background.FloorY)
				{
					ApplyForce(Gravity);
					Y += VelocityY;
				}

				if (IsAlive)
				{
					float collisionNormalX = 0;
					float collisionNormalY = 0;
					float collisionX = 0;
					float collisionY = 0;

					bool kill = false;
					if (Y + Height > Background.FloorY)
					{
						collisionX = Center.x;
						collisionY = Background.FloorY;
						collisionNormalY = -1;
						kill = true;
					}

					var rect = CollisionRect;
					for (let pipe in pipes)
					{
						for (var collisionRect in pipe.CollisionRects)
						{
							SDL.Rect intersecion;
							if (SDL.IntersectRect(&rect, &collisionRect, out intersecion))
							{
								kill = true;
								float cx = Center.x;
								float cy = Center.y;
								float ix = intersecion.x + 0.5f * intersecion.w;
								float iy = intersecion.y + 0.5f * intersecion.h;
								float nx = cx - ix;
								float ny = cy - iy;
								float nl = Math.Sqrt(nx*nx + ny*ny);
								collisionNormalX = nx / nl;
								collisionNormalY = ny / nl;
								collisionX = ix;
								collisionY = iy;
								break;
							}
						}
					}

					if (kill)
					{
						IsAlive = false;
						var center = Center;
						for (int i = 0; i < 20; ++i)
						{
							var angle = Rng.NextFloat(0, 360);
							var size = Rng.NextFloat(0.4f, 1.0f);
							var vx = Rng.NextFloat(-5, +5);
							var vy = Rng.NextFloat(-10, +10);
							var va = Rng.NextFloat(-10, +10);
							var b = Beef(center.x, center.y, angle, size, vx, vy, va);
							Beef.Add(b);
						}
						Audio.CowSplat.Play();
						
						ParticleEmmiter.Emit(
							200,
							0.5f,
							1000,
							collisionX,
							collisionY,
							20,
							collisionNormalX * 600,
							collisionNormalY * 600,
							600,
							SDL.Color(255, 0, 0, 255));
						
					}
				}
				else
				{
					for (int i = 0; i < Beef.Count; ++i)
						Beef[i].Update();
				}
			}
		}

		public void Draw(SDL.Renderer* renderer)
		{
			if (IsAlive)
			{
				AnimationTimeAccumulator += (.)AnimationTime.ElapsedSeconds;
				AnimationTime.Restart();
				while (AnimationTimeAccumulator >= SecondsPerFrame)
				{
					Frame = (Frame + 1) % Texture.CowAnimation.Count;
					AnimationTimeAccumulator -= SecondsPerFrame;
				}

				Texture.CowAnimation[Frame].Draw(renderer, X, Y);
			}

			for (int i = 0; i < Beef.Count; ++i)
				Beef[i].Draw(renderer);
		}

		public void Flap()
		{
			if (IsAlive)
			{
				Audio.Flap.Play();
				ApplyForce(JumpAcceleration);
			}
		}

		void ApplyForce(float force)
		{
			VelocityY = Math.Clamp(VelocityY + force, -MaxVelocity, MaxVelocity);
		}
	}
}
