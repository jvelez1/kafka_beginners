defmodule KafkaBeginnerTest do
  use ExUnit.Case
  doctest KafkaBeginner

  test "greets the world" do
    assert KafkaBeginner.hello() == :world
  end
end
