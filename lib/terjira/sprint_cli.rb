require_relative 'base_cli'

module Terjira
  class SprintCLI < BaseCLI

    desc "active", "show active sprint and issues on the board"
    jira_options :board, :assignee
    def active
      if options[:board].nil? || options[:board] == "board"
        board = select_board('scrum')
      else
        board = options[:board]
      end
      sprint = Client::Sprint.find_active(board)
      opts = suggest_options(required: [:sprint],
                             resouces: { board: board, sprint: sprint }
                            )
      opts[:assignee] ||= current_username
      issues = Client::Issue.all(opts)
      render_sprint_with_issues(sprint, issues)
    end

    desc "show [SPRINT_ID]", "show sprint"
    jira_option(:assignee)
    def show(sprint_id = nil)
      sprint = Client::Sprint.find(sprint_id)
      opts = suggest_options(required: [:sprint],
                             resouces: { sprint: sprint }
                            )
      opts[:assignee] ||= current_username
      issues = Client::Issue.all(opts)
      render_sprint_with_issues(sprint, issues)
    end

    desc "list(ls)", "list all sprint in BOARD"
    jira_options :board, :state
    map ls: :list
    def list
      opts = suggest_options(required: [:board])

      if opts[:board].type == 'kanban'
        return puts "Kanban board does not support sprints"
      end

      state = opts["sprint-state"].join(",")
      sprints = Client::Sprint.all(opts[:board], state: state)
      render_sprints_summary sprints
    end

    no_commands do
      def render_sprint_with_issues(sprint, issues)
        render_sprint_detail sprint
        render_divided_issues_by_status issues
      end
    end
  end
end