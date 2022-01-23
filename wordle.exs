
defmodule Wordle do
	@allow_repeats true
	@no_repeats false

	def words(allow_repeats \\ true, filename \\ "wordle.txt") do
		letters = filename
						|> File.read!
						|> String.split("\n", trim: true)
						|> Enum.map(fn line -> line |> String.split("", trim: true) end)
		letters = if not allow_repeats do
								letters |> Enum.filter(fn chars -> length(chars) == length(Enum.uniq(chars)) end)
							else
								letters
							end
		letters |> Enum.map(&Enum.with_index/1)
	end

	def frequencies(filename \\ "wordle.txt") do
		words(filename)
		|> List.flatten
		|> Enum.frequencies
	end

	def order(frequencies) do
		frequencies
		|> Enum.sort_by(fn {_, count} -> count end)
		|> Enum.reverse
	end

	def score(frequencies, {ch, i}) do
		0..4
		|> Enum.map(&(Map.get(frequencies, {ch, &1}, 0) * if(i == &1, do: 2, else: 1)))
		|> Enum.sum
	end

	def best_words(frequencies, allow_repeats \\ true, filename \\ "words.txt") do
		words(allow_repeats, filename)
		|> Enum.map(fn chars -> chars |> Enum.map(&score(frequencies, &1)) |> Enum.sum |> then(&{-&1, chars |> Enum.map_join(fn {ch,_} -> ch end)}) end)
		|> Enum.sort
		|> Enum.map_join("\n", fn {score, word} -> "#{word} #{-score}"end)
	end

	def tabulate(ordered) do
		0..4
		|> Enum.map(fn col -> ordered |> Enum.filter(fn {{_, i}, _} -> i == col end) |> Enum.map(fn {{ch,_}, _} -> ch end) end)
		|> Enum.zip_with(&(&1))
		|> Enum.map(&Enum.join(&1, ""))
		|> Enum.join("\n")
	end

	def solutions do
		filename = "wordle.txt"
		filename
		|> Wordle.frequencies
		|> Wordle.best_words(@allow_repeats, filename)
	end

	def tries do
		filename = "wordle_obscure.txt"
		filename
		|> Wordle.frequencies
		|> Wordle.best_words(@no_repeats, filename)
	end

	def letters_with_index(word), do: word |> String.split("", trim: true) |> Enum.with_index

	def judge(goal) do
		goal_letters = goal |> String.split("", trim: true)
		goal_set     = goal_letters |> MapSet.new
		goal_counts  = goal_letters |> Enum.frequencies
		fn guess ->
			guess_letters = guess |> String.split("", trim: true)
			guess_set     = guess_letters |> MapSet.new
			goal_letters
			|> Enum.zip(guess_letter)
			|> Enum.map_reduce(goal_counts, fn {gl, gs}, counts -> if gl == gs, do: {{:match, gl}, decrement(counts, g)}, else: {{gs}} )
		end
	end
end

filename = List.first(System.argv) || "wordle.txt"

filename
|> Wordle.frequencies
|> Wordle.best_words(filename)
|> IO.puts
