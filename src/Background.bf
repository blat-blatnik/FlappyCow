using SDL2;
using System;
using System.Collections;

namespace FlappyCow
{
	struct Background
	{
		public const int FloorHeight = 90;
		public const int FloorY = Game.Height - FloorHeight;

		public ParallaxLayer[3] layers;

		public this()
		{
			layers[0] = .(Texture.Clouds, 438, 2);
			layers[1] = .(Texture.Hills, 492, 1);
			layers[2] = .(Texture.Floor, FloorY, 0);
		}

		public void Update()
		{
			for (var layer in ref layers)
				layer.Update();
		}

		public void Draw(SDL.Renderer* renderer)
		{
			SDL.Rect background = .{ x = 0, y = 0, w = Game.Width, h = Game.Height };
			SDL.SetRenderDrawColor(renderer, 135, 206, 249, 255);
			SDL.RenderFillRect(renderer, &background);

			for (var layer in ref layers)
				layer.Draw(renderer);
		}
	}

	struct ParallaxLayer
	{
		public float X;
		public float Y;
		public float Distance;
		public Texture Texture;

		public this(Texture texture, float y, float distance)
		{
			Texture = texture;
			Distance = distance;
			X = 0;
			Y = y;
		}

		public void Update() mut
		{
			float factor = 1 / (1 + Distance);
			X -= factor * Pipe.Speed;

			while (X + Texture.Width < 0)
				X += Texture.Width;
		}

		public void Draw(SDL.Renderer* renderer)
		{
			for (float x = X; x < Game.Width; x += Texture.Width)
				Texture.Draw(renderer, x, Y);
		}
	}
}
