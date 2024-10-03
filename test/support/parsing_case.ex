defmodule NeoSaxyTest.ParsingCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnitProperties

      import NeoSaxyTest.Utils
    end
  end
end
