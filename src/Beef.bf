using SDL2;
using System;
using System.Collections;

namespace FlappyCow
{
	struct Beef
	{
		float X;
		float Y;
		float Angle;
		float Width;
		float Height;
		float VelocityX;
		float VelocityY;
		float AngularVelocity;

		const float Gravity = 0.3f;

		public this(float x, float y, float angle, float size, float velocityX, float velocityY, float angularVelocity)
		{
			X = x;
			Y = y;
			Angle = angle;
			VelocityX = velocityX;
			VelocityY = velocityY;
			AngularVelocity = angularVelocity;

			Width = size * Texture.Beef.Width;
			Height = size * Texture.Beef.Height;
		}

		public void Update() mut
		{
			X += VelocityX;
			Y += VelocityY;
			Angle += AngularVelocity;

			if (Y >= Background.FloorY)
			{
				if (VelocityY != 0) // Only play this when the beef hits the floor initially.
					Audio.BeefSplat.Play();
				VelocityX = 0;
				VelocityY = 0;
				AngularVelocity = 0;
			}
			else
				VelocityY += Gravity;
		}

		public void Draw(SDL.Renderer* renderer)
		{
			Texture.Beef.DrawRotated(renderer, X, Y, Width, Height, Angle);
		}
	}
}
