class Siege
  include Rails.application.routes.url_helpers

  def run
    SiegeSiege.run(
      time: 20,
      concurrent: 4,
      user_agent: false,
      urls:
        [
          "http://localhost:3002#{students_path}",
          "http://localhost:3002#{students_path} POST name=abc",
          SiegeSiege::URL.new("http://localhost:3002#{students_path}", :post, {name: 'abc'}),
        ] + Student.ids.shuffle[0..2].map { |id| "http://localhost:3002#{student_path(id)}" }
    )
  end
end