defprotocol NeoSaxy.Builder do
  @moduledoc """
  Protocol for building XML content.

  ## Deriving

  This helps to generate XML content simple form in trivial cases.

  There are a few required options:

  * `name` - tag name of generated XML element.
  * `attributes` - struct keys to be encoded as attributes.
  * `children` - a list of entries to be collected as element content. Each entry could be either:
    * key - value will be used as the content.
    * two-element tuple of key and transformer - struct value will be passed to the transformer.
      Transformer function could be a captured public function or a tuple of module and function.

  ### Examples

      defmodule Person do
        @derive {
          NeoSaxy.Builder,
          name: "person", attributes: [:gender], children: [:name, emails: &__MODULE__.build_emails/1]
        }

        import NeoSaxy.XML

        defstruct [:name, :gender, emails: []]

        def build_emails(emails) do
          count = Enum.count(emails)

          element(
            "emails",
            [count: Enum.count(emails)],
            Enum.map(emails, &element("email", [], &1))
          )
        end
      end

      iex> person = %Person{name: "Alice", gender: "female", emails: ["alice@foo.com", "alice@bar.com"]}
      iex> NeoSaxy.Builder.build(person)
      {"person", [{"gender", "female"}], ["Alice", {"emails", [{"count", "2"}], [{"email", [], ["alice@foo.com"]}, {"email", [], ["alice@bar.com"]}]}]}

  Custom implementation could be done by implementing protocol:

      defmodule User do
        defstruct [:username, :name]
      end

      defimpl NeoSaxy.Builder, for: User do
        import NeoSaxy.XML

        def build(user) do
          element(
            "Person",
            [{"userName", user.username}],
            [element("Name", [], user.name)]
          )
        end
      end

      iex> user = %User{name: "Alice", username: "alice99"}
      iex> NeoSaxy.Builder.build(user)
      {"Person", [{"userName", "alice99"}], [{"Name", [], ["Alice"]}]}
  """

  @doc """
  Builds `content` to XML content in simple form.
  """

  @spec build(content :: term()) :: NeoSaxy.XML.content() | list(NeoSaxy.XML.content())

  def build(content)
end

defimpl NeoSaxy.Builder, for: Any do
  defmacro __deriving__(module, _struct, options) do
    name = Keyword.fetch!(options, :name)
    attribute_fields = Keyword.get(options, :attributes, [])
    children_fields = Keyword.get(options, :children, [])

    quote do
      defimpl NeoSaxy.Builder, for: unquote(module) do
        def build(struct) do
          import NeoSaxy.XML

          attributes =
            struct
            |> Map.take(unquote(attribute_fields))
            |> Enum.to_list()

          children =
            Enum.map(
              unquote(children_fields),
              &unquote(__MODULE__).fetch_value(struct, &1)
            )

          element(unquote(name), attributes, children)
        end
      end
    end
  end

  def fetch_value(struct, {key, {transformer_module, transformer_fun}}) do
    apply(transformer_module, transformer_fun, [Map.fetch!(struct, key)])
  end

  def fetch_value(struct, {key, transformer_fun}) do
    apply(transformer_fun, [Map.fetch!(struct, key)])
  end

  def fetch_value(struct, key), do: Map.fetch!(struct, key)

  def build(%_{} = struct) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: struct,
      description: """
      NeoSaxy.Builder.Content doesn't know how to build this struct.

      You can derive the implementation by specifying in the module.

      @derive {
        NeoSaxy.Builder.Content,
        [name: "person",
         attributes: [:gender, :telephone],
         children: [:name]]
      }
      defstruct ...
      """
  end
end

defimpl NeoSaxy.Builder, for: Tuple do
  def build({type, _} = form)
      when type in [:characters, :comment, :cdata, :reference],
      do: form

  def build({_name, _attributes, _content} = form), do: form

  def build(other) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: other,
      description: "cannot build content with tuple"
  end
end

defimpl NeoSaxy.Builder, for: BitString do
  def build(binary) when is_binary(binary) do
    NeoSaxy.XML.characters(binary)
  end

  def build(bitstring) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: bitstring,
      description: "cannot build content with a bitstring"
  end
end

defimpl NeoSaxy.Builder, for: Atom do
  def build(nil), do: ""

  def build(value) do
    value
    |> Atom.to_string()
    |> NeoSaxy.XML.characters()
  end
end

defimpl NeoSaxy.Builder, for: Integer do
  def build(value) do
    value
    |> Integer.to_string()
    |> NeoSaxy.XML.characters()
  end
end

defimpl NeoSaxy.Builder, for: Float do
  def build(value) do
    value
    |> Float.to_string()
    |> NeoSaxy.XML.characters()
  end
end

defimpl NeoSaxy.Builder, for: NaiveDateTime do
  def build(value) do
    value
    |> NaiveDateTime.to_iso8601()
    |> NeoSaxy.XML.characters()
  end
end

defimpl NeoSaxy.Builder, for: DateTime do
  def build(value) do
    value
    |> DateTime.to_iso8601()
    |> NeoSaxy.XML.characters()
  end
end

defimpl NeoSaxy.Builder, for: Date do
  def build(value) do
    value
    |> Date.to_iso8601()
    |> NeoSaxy.XML.characters()
  end
end

defimpl NeoSaxy.Builder, for: Time do
  def build(value) do
    value
    |> Time.to_iso8601()
    |> NeoSaxy.XML.characters()
  end
end

defimpl NeoSaxy.Builder, for: List do
  def build(items) do
    Enum.map(items, &NeoSaxy.Builder.build/1)
  end
end
