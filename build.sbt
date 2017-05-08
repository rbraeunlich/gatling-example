lazy val root = project
  .in(file("."))
  .settings(
    name := "gatling-example",
    scalaVersion := "2.12.2",
    version := "0.1.0-SNAPSHOT",
    libraryDependencies ++= Seq(
        "io.gatling.highcharts" % "gatling-charts-highcharts" % "2.2.1" % "provided",
        "io.gatling" % "gatling-test-framework" % "2.2.1" % "provided"
    )
  ).enablePlugins(GatlingPlugin)