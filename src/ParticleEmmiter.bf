using SDL2;
using System;
using System.Collections;
using System.Diagnostics;

namespace FlappyCow
{
	struct Particle
	{
		public float x;
		public float y;
		public float vx;
		public float vy;
		public SDL.Color color;
	}

	class ParticleGroup
	{
		public Stopwatch Time ~ delete:null _;
		public float Gravity;
		public float Lifetime;
		public Particle[] Particles ~ delete:null _;

		[AllowAppend]
		public this(float gravity, float lifetime, int numParticles)
		{
			Stopwatch time = append Stopwatch();
			Particle[] particles = append Particle[numParticles];
			Time = time;
			Particles = particles;
			Gravity = gravity;
			Lifetime = lifetime;
			Time.Start();
		}

		public void Draw(SDL.Renderer* renderer)
		{
			float t = (.)Time.ElapsedSeconds;
			float timeFactor = Math.Clamp(1 - t / Lifetime, 0, 1);
			float alphaMult = Math.Clamp(timeFactor * timeFactor, 0, 1);
			for (var p in ref Particles)
			{
				float x = p.x + p.vx * t;
				float y = p.y + p.vy * t + 0.5f * Gravity * t * t;
				SDL.SetRenderDrawColor(renderer, p.color.r, p.color.g, p.color.b, (.)(alphaMult * p.color.a));
				//SDL.RenderDrawPoint(renderer, (.)x, (.)y);
				//
				// Larger particles look better - and they also cover more of the screen so we can use fewer for the same effect.
				SDL.Rect r = .{ x = (.)x, y = (.)y, w = 3, h = 3 };
				SDL.RenderDrawRect(renderer, &r);
			}
		}
	}

	static class ParticleEmmiter
	{
		static List<ParticleGroup> ParticleGroups = new .() ~ DeleteContainerAndItems!(_);
		static Random Random = new .() ~ delete _;

		public static void Emit(float gravity, float lifetime, int numParticles, float x, float y, float radius, float velocityX, float velocityY, float velocityRadius, params SDL.Color[] colors)
		{
			ParticleGroup pg = new ParticleGroup(gravity, lifetime, numParticles);
			for (var p in ref pg.Particles)
			{
				Random.NextPointInCircle(x, y, radius, out p.x, out p.y);
				Random.NextPointInCircle(velocityX, velocityY, velocityRadius, out p.vx, out p.vy);
				p.color = colors[Random.Next(colors.Count)];
			}
			ParticleGroups.Add(pg);
		}

		public static void Update()
		{
			for (int i = 0; i < ParticleGroups.Count; ++i)
			{
				var pg = ParticleGroups[i];
				if (pg.Time.ElapsedSeconds > pg.Lifetime)
				{
					delete pg;
					ParticleGroups.RemoveAt(i);
					--i;
				}
			}
		}

		public static void Draw(SDL.Renderer* renderer)
		{
			for (var pg in ParticleGroups)
				pg.Draw(renderer);
		}

		public static void Clear()
		{
			ClearAndDeleteItems!(ParticleGroups);
		}
	}
}
