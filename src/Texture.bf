using SDL2;
using System;

namespace FlappyCow
{
	struct Texture
	{
		public static Texture Beef;
		public static Texture Floor;
		public static Texture Clouds;
		public static Texture Hills;
		public static Texture PipeTop;
		public static Texture PipeMiddle;
		public static Texture PipeBottom;
		public static Texture Scoreboard;
		public static Texture Slider;
		public static Texture[21] CowAnimation;

		public static void LoadAll()
		{
			Beef = .("beef.png");
			Floor = .("floor.png");
			Clouds = .("clouds.png");
			Hills = .("hills.png");
			PipeTop = .("pipe-top.png");
			PipeMiddle = .("pipe-middle.png");
			PipeBottom = .("pipe-bottom.png");
			Scoreboard = .("scoreboard.png");
			Slider = .("slider.png");

			for (int i = 0; i < CowAnimation.Count; ++i)
				CowAnimation[i] = .(scope $"cow/frame{i:D4}.png");
		}

		public SDL.Surface* Surface;
		public SDL.Texture* Texture;
		public int Width;
		public int Height;

		public this(StringView filename)
		{
			String path = scope $"images/{filename}";

			Surface = SDLImage.Load(path.CStr());
			Texture = SDL.CreateTextureFromSurface(gApp.mRenderer, Surface);

			uint32 format;
			int32 access;
			int32 w, h;
			SDL.QueryTexture(Texture, out format, out access, out w, out h);
			Width = (.)w;
			Height = (.)h;
		}

		public void Draw(SDL.Renderer* renderer, float x, float y)
		{
			Draw(renderer, x, y, Width, Height);
		}
		public void Draw(SDL.Renderer* renderer, float x, float y, float width, float height)
		{
			SDL.Rect srcRect = .(0, 0, (.)Width, (.)Height);
			SDL.Rect destRect = .((.)x, (.)y, (.)width, (.)height);
			SDL.RenderCopy(renderer, Texture, &srcRect, &destRect);
		}
		public void DrawFlipped(SDL.Renderer* renderer, float x, float y)
		{
			DrawFlipped(renderer, x, y, Width, Height);
		}
		public void DrawFlipped(SDL.Renderer* renderer, float x, float y, float width, float height)
		{
			SDL.Rect srcRect = .(0, 0, (.)Width, (.)Height);
			SDL.Rect destRect = .((.)x, (.)y, (.)width, (.)height);
			SDL.RenderCopyEx(renderer, Texture, &srcRect, &destRect, 0, null, .Vertical);
		}
		public void DrawRotated(SDL.Renderer* renderer, float x, float y, float rotation)
		{
			DrawRotated(renderer, x, y, Width, Height, rotation);
		}
		public void DrawRotated(SDL.Renderer* renderer, float x, float y, float width, float height, float rotation)
		{
			SDL.Rect srcRect = .(0, 0, (.)Width, (.)Height);
			SDL.Rect destRect = .((.)x, (.)y, (.)width, (.)height);
			SDL.RenderCopyEx(renderer, Texture, &srcRect, &destRect, rotation, null, .None);
		}
	}
}
