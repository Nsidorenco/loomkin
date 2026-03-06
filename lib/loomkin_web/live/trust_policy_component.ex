defmodule LoomkinWeb.TrustPolicyComponent do
  @moduledoc """
  Functional component for selecting trust policy presets.

  Renders a compact row of preset buttons (Strict, Balanced, Autonomous, Full Trust)
  that control the session-wide permission behavior.
  """

  use Phoenix.Component

  attr :current_preset, :atom, required: true
  attr :class, :string, default: ""

  def trust_policy_selector(assigns) do
    ~H"""
    <div class={[
      "flex items-center gap-2 px-3 py-2 bg-gray-800/50 rounded-xl border border-gray-700/30",
      @class
    ]}>
      <span class="text-[10px] text-gray-500 uppercase tracking-wider">Trust</span>
      <div class="flex gap-1">
        <button
          :for={preset <- [:strict, :balanced, :autonomous, :full_trust]}
          phx-click="set_trust_preset"
          phx-value-preset={preset}
          class={[
            "px-2 py-1 text-[10px] rounded-lg transition-all",
            if(@current_preset == preset,
              do: "bg-violet-500/20 text-violet-400 border border-violet-500/30",
              else: "text-gray-500 hover:text-gray-400 hover:bg-gray-800"
            )
          ]}
        >
          {preset_label(preset)}
        </button>
      </div>
      <div
        class="w-2 h-2 rounded-full ml-1"
        style={"background: #{preset_color(@current_preset)};"}
        title={"Trust level: #{preset_label(@current_preset)}"}
      />
    </div>
    """
  end

  @doc """
  Returns a human-readable label for a preset name.
  """
  @spec preset_label(atom()) :: String.t()
  def preset_label(:strict), do: "Strict"
  def preset_label(:balanced), do: "Balanced"
  def preset_label(:autonomous), do: "Autonomous"
  def preset_label(:full_trust), do: "Full Trust"
  def preset_label(_), do: "Unknown"

  @doc """
  Returns a color hex string indicating the trust level.
  Green (strict/safe) through red (full trust/risky).
  """
  @spec preset_color(atom()) :: String.t()
  def preset_color(:strict), do: "#34d399"
  def preset_color(:balanced), do: "#fbbf24"
  def preset_color(:autonomous), do: "#f97316"
  def preset_color(:full_trust), do: "#ef4444"
  def preset_color(_), do: "#6b7280"
end
