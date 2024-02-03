# mission_test.exs

defmodule MissionTest do
  use ExUnit.Case

  describe "Mission" do
    import Mission

    test "load tasks from file when CSV file exists" do
      File.write!("tasks.csv", "name:Task1, description:Description1, priority:2\nname:Task2, description:Description2, priority:1")

      assert load_tasks_from_file() == [
        %Duty{name: "Task1", description: "Description1", priority: 2},
        %Duty{name: "Task2", description: "Description2", priority: 1}
      ]

      File.rm!("tasks.csv")
    end

    test "load tasks from file when CSV file does not exist" do
      assert load_tasks_from_file() == []

      # Cleanup: Delete the tasks.csv file if created during the previous test
      File.rm_f!("tasks.csv")
    end

    test "parse task with empty values" do
      assert parse_task(["" | _tail]) == %Duty{name: "", description: "", priority: 0}
    end

    test "parse task with valid values" do
      assert parse_task(["name:Task1", " description:Description1", " priority:2"]) == %Duty{name: "Task1", description: "Description1", priority: 2}
    end

    test "display tasks" do
      tasks = [%Duty{name: "Task1", description: "Description1", priority: 2}, %Duty{name: "Task2", description: "Description2", priority: 1}]

      assert capture_io(fn -> display_tasks(tasks) end) == "Task1\nTask2\n"

      tasks
    end

    test "display tasks when tasks are empty" do
      assert capture_io(fn -> display_tasks([]) end) == "No tasks to display.\n"
    end

    # Add more tests for other functions in Mission

    # Cleanup: Delete the tasks.csv file if created during the previous tests
    File.rm_f!("tasks.csv")
  end
end
