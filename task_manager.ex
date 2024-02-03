defmodule Task do
  @doc """
  Task struct representing a single task.

  This struct includes fields for the task title, description, priority, and date of creation.

  ## Examples

      iex> %Task{name: "Sample Task", description: "This is a sample task", priority: 2, date_of_creation: 1643651148}

  """
  defstruct [:name, :description, :priority, :date_of_creation]
end


defmodule TaskManager do
  @csv_file_path "tasks.csv"

  @doc """
  Start the Task Manager application.

  This function initializes the application by loading tasks from both command line input
  and the CSV file. It then enters the main menu loop for user interaction.

  ## Examples

      iex> TaskManager.start()

  """
  def start do
    tasks_from_input = load_tasks_from_input()
    tasks_from_file = load_tasks_from_file()

    tasks = tasks_from_input ++ tasks_from_file

    IO.puts("Tasks loaded successfully.")
    menu(tasks)
  end

  @doc """
  Display the main menu and handle user commands.

  This function displays the main menu with options for listing tasks, adding, deleting,
  and saving tasks, and quitting the application. It takes the user's choice and invokes
  the corresponding function.

  ## Examples

      iex> TaskManager.menu(tasks)

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
        1 -> display_tasks(tasks)
        2 -> display_comprehensible(tasks)
        3 -> add_task(tasks)
        4 -> delete_task(tasks)
        5 -> save_tasks(tasks)
        6 -> change_order_by_priority(tasks)
        7 -> IO.puts("Exiting the Task Manager. Goodbye!"); System.halt(0)
        _ -> IO.puts("Invalid choice. Please try again."); tasks
      end

    menu(tasks)
  end

  @doc """
  Load tasks from the command line input.

  This function prompts the user to enter tasks from the command line input. It continues
  to read tasks until the user types 'exit'.

  ## Examples

      iex> TaskManager.load_tasks_from_input()

  """
  def load_tasks_from_input do
    IO.puts("Enter tasks from input (press Enter after each task; type 'exit' to finish):")
    load_tasks_loop([])
  end

  defp load_tasks_loop(tasks) do
    task = IO.gets("Type 'exit' to finish: ") |> String.trim()

    case task do
      "exit" -> tasks
      _ -> load_tasks_loop([parse_task(String.split(task, ",")) | tasks])
    end
  end

  @doc """
  Load tasks from the CSV file.

  This function reads tasks from the specified CSV file. If successful, it returns a
  list of tasks; otherwise, it prints an error message and returns an empty list.

  ## Examples

      iex> TaskManager.load_tasks_from_file()

  """
  def load_tasks_from_file do
    case File.read(@csv_file_path) do
      {:ok, content} ->
        Enum.map(String.split_lines(content), &String.split(&1, ","))
        |> Enum.map(&parse_task/1)

      {:error, reason} ->
        IO.puts("Error reading tasks from CSV file: #{reason}")
        []
    end
  end

  defp parse_task([name, description, priority]) do
    %Task{name: name  "", description: description  "", priority: String.to_integer(priority || "0")}
  end


  @doc """
  Display the list of tasks.

  This function takes a list of tasks and displays them using IO.inspect.

  ## Examples

      iex> TaskManager.display_tasks(tasks)
  """
  def display_tasks(tasks) do
    Enum.each(tasks, &IO.inspect/1)
  end

  @doc """
  Display tasks in a comprehensible format.

  This function takes a list of tasks and displays each task in a formatted,
  comprehensible manner using IO.puts.

  ## Examples

      iex> TaskManager.display_comprehensible(tasks)
  """
  def display_comprehensible(tasks) do
    Enum.each(tasks, &display_task/1)
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

      iex> TaskManager.add_task(tasks)
  """
  def add_task(tasks) do
    IO.puts("Enter task details:")
    name = IO.gets("Name: ") |> String.trim()
    description = IO.gets("Description: ") |> String.trim()
    priority = IO.gets("Priority: ") |> String.trim() |> String.to_integer()

    new_task = %Task{name: name, description: description, priority: priority}
    [new_task | tasks]
  end

  @doc """
  Delete a task from the list.

  This function prompts the user to enter the name of the task to be deleted.
  It then removes the task from the list and displays a message indicating the deletion.

  ## Examples

      iex> TaskManager.delete_task(tasks)
  """
  def delete_task(tasks) do
    IO.puts("Enter task name to delete:")
    name_to_delete = IO.gets() |> String.trim()

    updated_tasks = Enum.reject(tasks, &(&1.name == name_to_delete))
    IO.puts("Task '#{name_to_delete}' deleted.")
    updated_tasks
  end

  @doc """
  Change the order of tasks by priority.

  This function takes a list of tasks and rearranges them in ascending order based
  on their priority.

  ## Examples

      iex> TaskManager.change_order_by_priority(tasks)
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
  them to the specified CSV file.

  ## Examples

      iex> TaskManager.save_tasks(tasks)
  """
  def save_tasks(tasks) do
    tasks_as_strings = tasks |> Enum.map(&format_task/1) |> Enum.join("\n")
    File.write!(@csv_file_path, tasks_as_strings)
    IO.puts("Tasks saved to #{@csv_file_path}")
  end

  defp format_task(task) do
    "#{task.name},#{task.description},#{task.priority}"
  end
end

TaskManager.start()

defmodule TaskManagerTest do
  use ExUnit.Case

  describe "TaskManager" do
    import TaskManager

    setup do
      tasks = [
        %Task{
          name: "Task1",
          description: "Description1",
          priority: 2,
          date_of_creation: 1_643_651_148
        },
        %Task{
          name: "Task2",
          description: "Description2",
          priority: 1,
          date_of_creation: 1_643_651_150
        }
      ]

      {:ok, tasks: tasks}
    end

    @doc "Test loading tasks from command line input"
    test "load tasks from input" do
      assert load_tasks_from_input() == [
               %Task{
                 name: "Task1",
                 description: "Description1",
                 priority: 2,
                 date_of_creation: 1_643_651_148
               },
               %Task{
                 name: "Task2",
                 description: "Description2",
                 priority: 1,
                 date_of_creation: 1_643_651_150
               }
             ]
    end

    @doc "Test loading tasks from CSV file"
    test "load tasks from file" do
      assert load_tasks_from_file() == [
               %Task{
                 name: "TaskFromFile",
                 description: "DescriptionFromFile",
                 priority: 3,
                 date_of_creation: 1_643_651_160
               }
             ]
    end

    @doc "Test starting the TaskManager application"
    test "start the TaskManager application" do
      assert TaskManager.start() == :ok
    end

    @doc "Test displaying tasks in a comprehensible format"
    test "display tasks in comprehensible format" do
      assert TaskManager.display_comprehensible(@tasks) == :ok
    end

    @doc "Test adding a task to the list"
    test "add a task to the list" do
      updated_tasks = TaskManager.add_task(@tasks)
      assert length(updated_tasks) == length(@tasks) + 1
    end

    @doc "Test deleting a task from the list"
    test "delete a task from the list" do
      updated_tasks = TaskManager.delete_task(@tasks)
      assert length(updated_tasks) == length(@tasks) - 1
    end

    @doc "Test changing the order of tasks by priority"
    test "change order of tasks by priority" do
      sorted_tasks = TaskManager.change_order_by_priority(@tasks)
      assert Enum.sort(&less_than_priority/2, @tasks) == sorted_tasks
    end

    @doc "Test saving tasks to CSV file"
    test "save tasks to CSV file" do
      assert TaskManager.save_tasks(@tasks) == :ok
    end
  end

  describe "Task" do
    import Task

    @doc "Test creating a task struct"
    test "create task struct" do
      task = %Task{
        name: "TestTask",
        description: "TestDescription",
        priority: 3,
        date_of_creation: 1_643_651_170
      }

      assert task.name == "TestTask"
      assert task.description == "TestDescription"
      assert task.priority == 3
      assert task.date_of_creation == 1_643_651_170
    end
  end
end
