defmodule CMS.Bibles.PassageTest do
  use ExUnit.Case, async: true
  alias CMS.Bibles.Passage

  @usfm_index %{
    "genesis" => "GEN",
    "exodo" => "EXO",
    "levitico" => "LEV",
    "joao" => "JHN",
    "salmos" => "PSA",
    "salmo" => "PSA",
    "cantares" => "SNG"
  }

  @opts %{usfm_index: @usfm_index}

  describe "parse/2" do
    test "parses multi-chapter references" do
      assert Passage.parse("Génesis 1:1-2:3", @opts) == {:ok, {"GEN", 1, 1}, {"GEN", 2, 3}}
      assert Passage.parse("Cantares 1:5-2:10", @opts) == {:ok, {"SNG", 1, 5}, {"SNG", 2, 10}}
    end

    test "parses multi-verse references" do
      assert Passage.parse("Êxodo 20:1-17", @opts) == {:ok, {"EXO", 20, 1}, {"EXO", 20, 17}}
      assert Passage.parse("Salmos 119:10-15", @opts) == {:ok, {"PSA", 119, 10}, {"PSA", 119, 15}}
    end

    test "parses single-verse references" do
      assert Passage.parse("João 3:16", @opts) == {:ok, {"JHN", 3, 16}, {"JHN", 3, 16}}
    end

    test "parses single-chapter references" do
      assert Passage.parse("Salmo 23", @opts) == {:ok, {"PSA", 23, 1}, {"PSA", 23, 9999}}
      assert Passage.parse("Levítico 1", @opts) == {:ok, {"LEV", 1, 1}, {"LEV", 1, 9999}}
    end

    test "handles book name normalization" do
      assert Passage.parse("genesis 1:1", @opts) == {:ok, {"GEN", 1, 1}, {"GEN", 1, 1}}
      assert Passage.parse("GENESIS 1:1", @opts) == {:ok, {"GEN", 1, 1}, {"GEN", 1, 1}}
      assert Passage.parse("  João  3:16  ", @opts) == {:ok, {"JHN", 3, 16}, {"JHN", 3, 16}}
      assert Passage.parse("Cantares 1:1", @opts) == {:ok, {"SNG", 1, 1}, {"SNG", 1, 1}}
    end

    test "returns error for unknown book" do
      assert Passage.parse("UnknownBook 1:1", @opts) == {:error, "unknownbook 1:1"}
    end

    test "returns error for invalid format" do
      assert Passage.parse("Genesis", @opts) == {:error, "genesis"}
      assert Passage.parse("Genesis 1:", @opts) == {:error, "genesis 1:"}
      assert Passage.parse("Genesis 1a:3", @opts) == {:error, "genesis 1a:3"}
      assert Passage.parse("Genesis 1:1-", @opts) == {:error, "genesis 1:1-"}
      assert Passage.parse("Genesis 1:A", @opts) == {:error, "genesis 1:a"}
      assert Passage.parse("Genesis A:1", @opts) == {:error, "genesis a:1"}
      assert Passage.parse("Genesis 1:1-2:B", @opts) == {:error, "genesis 1:1-2:b"}
      assert Passage.parse("Genesis 1:1-B:3", @opts) == {:error, "genesis 1:1-b:3"}

      assert Passage.parse("Genesis 1:1-UnknownBook 2:3", @opts) ==
               {:error, "genesis 1:1-unknownbook 2:3"}
    end

    test "returns error for completely unparseable string" do
      assert Passage.parse("this is not a passage", @opts) ==
               {:error, "this is not a passage"}
    end
  end
end
