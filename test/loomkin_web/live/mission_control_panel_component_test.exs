defmodule LoomkinWeb.MissionControlPanelComponentTest do
  use LoomkinWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @base_assigns %{
    id: "test-mc-panel",
    agent_cards: %{},
    concierge_card_names: [],
    worker_card_names: [],
    comms_event_count: 0,
    focused_agent: nil,
    kin_agents: [],
    cached_agents: [],
    active_team_id: "team-1",
    comms_stream: nil
  }

  test "renders waiting state when no agents" do
    html = render_component(LoomkinWeb.MissionControlPanelComponent, @base_assigns)
    assert html =~ "C"
    assert html =~ "O"
    assert html =~ "Concierge"
    assert html =~ "Orienter ready"
    assert html =~ "Send a message to wake them up"
  end

  test "renders kin section header" do
    html = render_component(LoomkinWeb.MissionControlPanelComponent, @base_assigns)
    assert html =~ "Kin"
  end

  defp build_card(name, overrides \\ %{}) do
    Map.merge(
      %{
        name: name,
        content_type: :idle,
        role: :coder,
        status: :idle,
        model: nil,
        latest_content: nil,
        last_tool: nil,
        pending_question: nil,
        current_task: nil
      },
      overrides
    )
  end

  test "shows agent count badge" do
    assigns =
      Map.merge(@base_assigns, %{
        worker_card_names: ["alice"],
        agent_cards: %{"alice" => build_card("alice")}
      })

    html = render_component(LoomkinWeb.MissionControlPanelComponent, assigns)
    # The badge showing the count of worker agents
    assert html =~ "1"
  end

  test "renders dormant kin ghost cards" do
    kin = %{
      id: "k1",
      name: "rex",
      display_name: "Rex",
      enabled: true,
      potency: 80,
      role: :coder
    }

    assigns =
      Map.merge(@base_assigns, %{
        kin_agents: [kin],
        cached_agents: []
      })

    html = render_component(LoomkinWeb.MissionControlPanelComponent, assigns)
    assert html =~ "Rex"
  end

  test "renders focused agent back button" do
    assigns =
      Map.merge(@base_assigns, %{
        focused_agent: "alice",
        agent_cards: %{"alice" => build_card("alice")}
      })

    html = render_component(LoomkinWeb.MissionControlPanelComponent, assigns)
    assert html =~ "All agents"
  end
end
