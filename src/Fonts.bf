using SDL2;
using System;

namespace FlappyCow
{
	static class Fonts
	{
		public static SDLTTF.Font* Big;

		public static void LoadAll()
		{
			Big = SDLTTF.OpenFont("fonts/PermanentMarker-Regular.ttf", 48);
		}
	}

	class DrawString
	{
		SDLTTF.Font* Font;
		String Text ~ delete _;
		int Width;
		int Height;
		SDL.Color Color;
		SDL.Surface* Surface;
		SDL.Texture* Texture;
		SDL.Renderer* Renderer;

		public this(SDLTTF.Font* font, SDL.Renderer* renderer, StringView text, SDL.Color color)
		{
			Font = font;
			Color = color;
			Renderer = renderer;
			Text = new String();
			SetText(text);
		}

		public void Draw(StringView text, float x, float y, float scale = 1, bool centered = true)
		{
			SetText(text);

			var x;
			var y;
			if (centered)
			{
				x -= scale * Width * 0.5f;
				y -= scale * Height * 0.5f;
			}

			SDL.Rect srcRect = .(0, 0, Surface.w, Surface.h);
			SDL.Rect destRect = .((.)x, (.)y, .(scale * Surface.w), .(scale * Surface.h));
			SDL.RenderCopy(Renderer, Texture, &srcRect, &destRect);
		}

		void SetText(StringView newText)
		{
			if (StringView(Text) == newText)
				return;

			Text.Set(newText);
			char8* cstr = Text.CStr();
			SDLTTF.SizeText(Fonts.Big, cstr, out Width, out Height);

			if (Surface != null)
				SDL.FreeSurface(Surface);
			if (Texture != null)
				SDL.DestroyTexture(Texture);

			Surface = SDLTTF.RenderText_Blended(Font, cstr, Color);
			Texture = SDL.CreateTextureFromSurface(Renderer, Surface);
		}
	}
}
