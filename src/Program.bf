namespace FlappyCow
{
	static class Program
	{
		public static Game Game;

		static void Main()
		{
			Game = scope Game();
			Game.Init();
			Game.Run();
		}
	}
}
