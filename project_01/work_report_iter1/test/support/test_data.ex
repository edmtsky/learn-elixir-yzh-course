defmodule TestData do
  alias WorkReport.Model.Month
  alias WorkReport.Model.Day
  alias WorkReport.Model.Task

  @doc """
  based on test/sample/report-1.md
  """
  def valid_month_from_report_1() do
    %Month{
      name: :may,
      days: [
        %Day{
          num: 5,
          day_of_week: :wednesday,
          tasks: [
            %Task{category: :dev, description: "Task-44 Implement", time: 52},
            %Task{category: :comm, description: "Task-44 discuss with BA", time: 21},
            %Task{category: :doc, description: "Task-44 read BA documents", time: 32},
            %Task{category: :dev, description: "Task-43 write tests", time: 38},
            %Task{category: :dev, description: "Task-43 Impletent feature", time: 54},
            %Task{category: :dev, description: "Task-43 Impletent feature", time: 31},
            %Task{category: :comm, description: "Daily Meeting", time: 16},
            %Task{category: :dev, description: "Review Pull Requests", time: 39}
          ]
        },
        %Day{
          num: 4,
          day_of_week: :tuesday,
          tasks: [
            %Task{category: :dev, description: "TASK 42 Fix and test", time: 37},
            %Task{category: :dev, description: "TASK-42 Test", time: 22},
            %Task{category: :dev, description: "TASK-42 Implement feature", time: 46},
            %Task{category: :doc, description: "Read Service T API documents", time: 11},
            %Task{category: :comm, description: "Sprint Review & Retro", time: 95},
            %Task{category: :doc, description: "Read Service T API documents", time: 19},
            %Task{category: :doc, description: "TASK-42 Read BA documents", time: 15},
            %Task{category: :comm, description: "Daily Meeting", time: 31}
          ]
        },
        valid_day_3monday_8tasks()
      ]
    }
  end

  def valid_day_3monday_8tasks() do
    %Day{
      num: 3,
      day_of_week: :monday,
      tasks: [
        %Task{category: :doc, description: "Write a document about logs in ELK", time: 22},
        %Task{category: :dev, description: "Learn how to search for logs in Kibana", time: 34},
        %Task{category: :ops, description: "Setup Kibana", time: 17},
        %Task{category: :ops, description: "Setup Elasticsearch", time: 39},
        %Task{category: :dev, description: "Implement filters for Logstash", time: 57},
        %Task{category: :dev, description: "Implement filters for Logstash", time: 39},
        %Task{category: :comm, description: "Daily Meeting", time: 15},
        %Task{category: :dev, description: "Review Pull Requests", time: 27}
      ]
    }
  end

  def valid_dev_task_pull_req_27m() do
    %Task{category: :dev, description: "Review Pull Requests", time: 27}
  end

  def valid_report_1_month_totals() do
    %WorkReport.Model.Report.MonthTotals{
      categories_time: %{
        ops: 56,
        dev: 476,
        doc: 99,
        edu: 0,
        comm: 178,
        ws: 0
      },
      total_time: 809,
      days_cnt: 3,
      avg_day_time: 269
    }
  end

  def valid_report_1() do
    %WorkReport.Model.Report{
      day: valid_day_3monday_8tasks(),
      month_name: :may,
      day_totals: 250,
      month_totals: valid_report_1_month_totals()
    }
  end
end
