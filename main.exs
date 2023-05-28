defmodule Redactor do

  def redact_inverse(redactWordsFilePath, fileToRedact) do

    redactedWords = handleRead(File.read(redactWordsFilePath),false)

    wordsToRedact = handleRead(File.read(fileToRedact),true)

    redactHelper(redactedWords,wordsToRedact,true)

    IO.puts("")

  end

  def redact(redactWordsFilePath, fileToRedact) do

    redactedWords = handleRead(File.read(redactWordsFilePath),false)

    wordsToRedact = handleRead(File.read(fileToRedact),true)

    redactHelper(redactedWords,wordsToRedact,false)

    IO.puts("")

  end

  defp redactHelper(redactedWordsInput, wordsToRedact,redactOrInverse) do
    
    Enum.each(wordsToRedact,fn x -> toRedact(x,redactedWordsInput,redactOrInverse) end)
    
  end

  defp toRedact(wordToRedact,redactedList,redactOrInverse) do
    String.graphemes(wordToRedact) |>
    Enum.find_value(false,fn x -> x == "\r\n" end) |>
    toSplitOrNot(wordToRedact,redactedList,redactOrInverse)

  end

  defp toSplitOrNot(true, wordInput, redactedListInput, redactOrInverse)  do
    enumList = String.graphemes(wordInput)
    listOfNewlines = Enum.filter(enumList, fn x -> x == "\r\n" end)
    String.split(wordInput, ["\r\n"]) |>
    addNewlines(0,length(listOfNewlines)) |>
    Enum.each(fn x -> splitHelper(x,redactedListInput,redactOrInverse) end)
    
  end

  defp toSplitOrNot(false, wordInput, redactedListInput, redactOrInverse) do
    lowerWordInput = String.downcase(wordInput)
    printWordHelper(lowerWordInput, wordInput, redactedListInput, redactOrInverse)

  end

  defp addNewlines(wordListToAdd, currentSpot, amountToAdd) when currentSpot < amountToAdd do
    spotToAdd = currentSpot + 1
    List.insert_at(wordListToAdd,spotToAdd, "\r\n") |>
    addNewlines(spotToAdd,amountToAdd)

  end

  defp addNewlines(wordListToAdd, currentSpot, amountToAdd) when currentSpot >= amountToAdd do
    wordListToAdd

  end

  defp splitHelper(wordInput,redactedListInput, redactOrInverse) do
    lowerWordInput = String.downcase(wordInput)
    printWordHelper(lowerWordInput, wordInput, redactedListInput, redactOrInverse)

  end

  defp printWordHelper(loweredCaseWordInput, wordInput,redactedListInput,true) do
    
    Enum.find_value(redactedListInput,false,fn x -> x == loweredCaseWordInput end ) |> printWord(wordInput)

  end

  defp printWordHelper(loweredCaseWordInput, wordInput,redactedListInput,false) do
    truFalseVal = Enum.find_value(redactedListInput,false,fn x -> x == loweredCaseWordInput end )
    printWord(!truFalseVal,wordInput)

  end

  defp printWord(true, theWordInput) do
    IO.write(theWordInput)
    IO.write(" ")

  end

  defp printWord(false, theWordInput) do
    
    IO.write(String.replace(theWordInput,~r/[a-z'\-*]|[0-9*] /i,"*",global: true))
    IO.write(" ")

  end

  defp handleRead({:ok, file_contents}, true) do
    String.split(file_contents, [" ", ","])
  end

  defp handleRead({:ok, file_contents}, false) do
    String.split(file_contents)
  end

  defp handleRead({:error, :enoent},[true,false]) do #error no entry
    IO.puts("The file does not exist")
    exit(:shutdown)
  end

  defp handleRead({:error, :eisdir},[true,false]) do #error is a directory
    IO.puts("You specified a directory not a file")
    exit(:shutdown)
  end


end

Redactor.redact_inverse("1000words.txt", "sqrt110.txt")
IO.puts("")
IO.puts("")
Redactor.redact("1000words.txt", "sqrt110.txt")