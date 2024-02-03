defmodule Duty do
  @doc """
  Duty struct representing a single task.

  This struct includes fields for the task title, description, priority, and date of creation.

  ## Examples

      iex> %Duty{name: "Sample Task", description: "This is a sample task", priority: 2}

  """
  defstruct [:name, :description, :priority]
end

defmodule Mission do
  @csv_file_path "tasks.csv"

  @doc """
  Start the Mission application.

  This function initializes the application by loading tasks from
  the CSV file. It then enters the main menu loop for user interaction.

  ## Examples

      iex> Mission.start()

  """
  def start do
    case File.read(@csv_file_path) do
      {:ok, content} ->
        tasks =
          content
          |> String.split("\n")
          |> reject_empty_lines()
          |> Enum.map(&String.split(&1, ","))
          |> Enum.map(&parse_task/1)

        case tasks do
          [] ->
            IO.puts("No tasks loaded from the file.")
            Mission.menu([])

          _ ->
            IO.puts("Tasks loaded successfully.")
            Mission.menu(tasks)
        end

      {:error, _reason} ->
        IO.puts("CSV file not found.")
        Mission.menu([])
    end
  end

  defp reject_empty_lines(lines) do
    Enum.reject(lines, fn line -> String.trim(line) == "" end)
  end

  @doc """
  Display the main menu and handle user commands.

  This function displays the main menu with options for listing tasks, adding, deleting,
  and saving tasks, and quitting the application. It takes the user's choice and invokes
  the corresponding function.

  ## Examples

      iex> Mission.menu(tasks)

  """
  def menu(tasks) do
    IO.puts("Task Manager Menu:")
    IO.puts("1. List tasks")
    IO.puts("2. Show tasks")
    IO.puts("3. Add task")
    IO.puts("4. Delete task")
    IO.puts("5. Save tasks to CSV")
    IO.puts("6. Change task order by priority")
    IO.puts("7. Quit")

    choice = IO.gets("Enter your choice: ") |> String.trim() |> String.to_integer()

    tasks =
      case choice do
        1 ->
          display_tasks(tasks)

        2 ->
          display_comprehensible(tasks)

        3 ->
          add_task(tasks)

        4 ->
          delete_task(tasks)

        5 ->
          save_tasks(tasks)

        6 ->
          change_order_by_priority(tasks)

        7 ->
          IO.puts("Goodbye!")
          System.halt(0)

        _ ->
          IO.puts("Invalid choice. Please try again.")
          tasks
      end

    menu(tasks)
  end

  @doc """
  Load tasks from the CSV file.

  This function reads tasks from the specified CSV file. If successful, it returns a
  list of tasks; otherwise, it prints an error message and returns an empty list.

  ## Examples

      iex> Mission.load_tasks_from_file()

  """
  def load_tasks_from_file do
    case File.read(@csv_file_path) do
      {:ok, content} ->
        tasks =
          content
          |> String.split("\n")
          |> Enum.map(&String.split(&1, ","))
          |> Enum.map(&parse_task/1)

        tasks

      {:error, reason} ->
        IO.puts("Error reading tasks from CSV file: #{reason}")
        []
    end
  end

  defp parse_task(["" | _tail]) do
    %Duty{name: "", description: "", priority: 0}
  end

  defp parse_task([name, description, priority]) do
    %Duty{
      name: String.trim_leading(name, "name: ") |> String.trim(),
      description: String.trim_leading(description, " description: ") |> String.trim(),
      priority: String.trim_leading(priority, " priority: ") |> String.to_integer()
    }
  end

  @doc """
  Display the list of tasks.

  This function takes a list of tasks and displays them using IO.inspect.

  ## Examples

      iex> Mission.display_tasks(tasks)
  """
  def display_tasks(tasks) do
    case tasks do
      {:error, reason} ->
        IO.puts("Error: #{reason}")

      [] ->
        IO.puts("No tasks to display.")

      _ ->
        Enum.each(tasks, &IO.inspect/1)
    end

    tasks
  end

  @doc """
  Display tasks in a comprehensible format.

  This function takes a list of tasks and displays each task in a formatted,
  comprehensible manner using IO.puts.

  ## Examples

      iex> Mission.display_comprehensible(tasks)
  """

  def display_comprehensible(tasks) do
    Enum.each(tasks, &display_task/1)
    tasks
  end

  defp display_task(task) do
    IO.puts("Task:")
    IO.puts("Name: #{task.name}")
    IO.puts("Description: #{task.description}")
    IO.puts("Priority: #{task.priority}")
    IO.puts("---------")
  end

  @doc """
  Add a new task to the list.

  This function prompts the user to enter details for a new task, including
  name, description, and priority. It then creates a new task struct and adds it
  to the list of tasks.

  ## Examples

      iex> Mission.add_task(tasks)
  """
  def add_task(tasks) do
    IO.puts("Enter task details:")
    name = IO.gets("Name: ") |> String.trim()
    description = IO.gets("Description: ") |> String.trim()
    priority = IO.gets("Priority: ") |> String.trim() |> String.to_integer()

    new_task = %Duty{name: name, description: description, priority: priority}
    [new_task | tasks]
  end

  @doc """
  Delete a task from the list.

  This function prompts the user to enter the name of the task to be deleted.
  It then removes the task from the list and displays a message indicating the deletion.

  ## Examples

      iex> Mission.delete_task(tasks)
  """
  def delete_task(tasks) do
    name_to_delete = IO.gets("Enter task name to delete:") |> String.trim()

    updated_tasks = Enum.reject(tasks, &(&1.name == name_to_delete))
    IO.puts("Task '#{name_to_delete}' deleted.")
    updated_tasks
  end

  @doc """
  Change the order of tasks by priority.

  This function takes a list of tasks and rearranges them in ascending order based
  on their priority.

  ## Examples

      iex> Mission.change_order_by_priority(tasks)
  """
  def change_order_by_priority(tasks) do
    tasks |> Enum.sort(&less_than_priority/2)
  end

  defp less_than_priority(task1, task2) do
    task1.priority < task2.priority
  end

  @doc """
  Save tasks to the CSV file.

  This function takes a list of tasks, formats them into CSV strings, and writes
  them to the specified CSV file. It then reloads the tasks from the file.

  ## Examples

      iex> Mission.save_tasks(tasks)
  """
  def save_tasks(tasks) do
    tasks_as_strings = tasks |> Enum.map(&format_task/1) |> Enum.join("\n")
    File.write!(@csv_file_path, tasks_as_strings)
    IO.puts("Tasks saved to #{@csv_file_path}")

    # Reload tasks from the file after saving
    load_tasks_from_file()
  end

  defp format_task(task) do
    "name: #{task.name}, description: #{task.description}, priority: #{task.priority}"
  end
end

Mission.start()
