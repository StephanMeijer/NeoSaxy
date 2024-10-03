defmodule NeoSaxy.TestHandlers.StackHandler do
  @behaviour NeoSaxy.Handler

  def handle_event(event_type, event_data, acc) do
    {:ok, [{event_type, event_data} | acc]}
  end
end

defmodule NeoSaxyTest.StackHandler do
  @behaviour NeoSaxy.Handler

  @impl true
  def handle_event(event_type, event_data, acc) do
    {:ok, [{event_type, event_data} | acc]}
  end
end

defmodule NeoSaxyTest.ControlHandler do
  @behaviour NeoSaxy.Handler

  @impl true
  def handle_event(event_type, _, {event_type, returning}) do
    returning
  end

  def handle_event(event_type, event_data, {{event_type, event_data}, returning}) do
    returning
  end

  def handle_event(_, _, state) do
    {:ok, state}
  end
end

# For docs test

defmodule MyTestHandler do
  @behaviour NeoSaxy.Handler

  def handle_event(:start_document, prolog, state) do
    {:ok, [{:start_document, prolog} | state]}
  end

  def handle_event(:end_document, _data, state) do
    {:ok, [{:end_document} | state]}
  end

  def handle_event(:start_element, {name, attributes}, state) do
    {:ok, [{:start_element, name, attributes} | state]}
  end

  def handle_event(:end_element, name, state) do
    {:ok, [{:end_element, name} | state]}
  end

  def handle_event(:characters, chars, state) do
    {:ok, [{:chacters, chars} | state]}
  end
end

defmodule Person do
  @derive {
    NeoSaxy.Builder,
    name: "person", attributes: [:gender], children: [:name, emails: &__MODULE__.build_emails/1]
  }

  import NeoSaxy.XML

  defstruct [:name, :gender, emails: []]

  def build_emails(emails) do
    email_count = Enum.count(emails)

    element(
      "emails",
      [count: email_count],
      Enum.map(emails, &element("email", [], &1))
    )
  end
end

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
