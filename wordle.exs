
defmodule Wordle do
	def words(filename \\ "words.txt") do
		filename
		|> File.read!
		|> String.split("\n", trim: true)
		|> Enum.map(fn line -> line |> String.split("", trim: true) end)
		|> Enum.filter(fn chars -> length(chars) == length(Enum.uniq(chars)) end)
		|> Enum.map(&Enum.with_index/1)
	end

	def frequencies(filename \\ "words.txt") do
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

	def best_words(frequencies, filename \\ "words.txt") do
		words(filename)
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
end

Wordle.frequencies
|> Wordle.best_words
|> IO.puts
