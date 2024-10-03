defmodule NeoSaxy.Parser do
  @moduledoc false

  defmodule Binary do
    @moduledoc false

    use NeoSaxy.Parser.Builder, streaming?: false
  end

  defmodule Stream do
    @moduledoc false

    use NeoSaxy.Parser.Builder, streaming?: true
  end
end
