command :step, short: :s do
  TracePoint.trace(:call, :return, :line) do |trace|
    next if Filter.internal?(trace.path)

    case trace.event
    when :call
      trace.disable

      context = Context.new([*current.frames, trace.binding])
      context.start
    when :return
      current.frames.pop
      current.depth -= 1
    when :line
      next if current.depth.positive?

      trace.disable

      context = Context.new([*current.frames[0...-1], trace.binding])
      context.start
    end
  end

  current.stop
end
