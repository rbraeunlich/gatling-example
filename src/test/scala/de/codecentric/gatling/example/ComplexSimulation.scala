package de.codecentric.gatling.example

import io.gatling.core.Predef._
import io.gatling.core.scenario.Simulation
import io.gatling.http.Predef._

/**
  * Created by ronny on 08.05.17.
  */
class ComplexSimulation extends Simulation {

  private val httpConfig = http.baseURL("http://computer-database.gatling.io")

  private val scn = scenario("SimpleSimulation").
    exec(http("open").
      get("/")).
    pause(1)

  private val numberFeeder = for( x <- 0 until 10 ) yield Map("veryImportantId" -> x)

  private val addComputer = scenario("Add Computer").
    feed(numberFeeder.iterator).
    exec(http("create new computer").
      post("/computers").
    formParamMap(Map("name" -> "Codecentric Machine ${veryImportantId}"))).
    exec(s => {s.attributes.foreach(println(_)); s})

  private val checkComputer = scenario("Check Computer").
    feed(numberFeeder.iterator).
    exec(http("request computer").
    get("/computers?f=Codecentric Machine ${veryImportantId}").
    check(css("a:contains('Codecentric Machine ${veryImportantId}')", "href")))

  setUp(
    addComputer.inject(atOnceUsers(10)),
    checkComputer.pause(4).inject(atOnceUsers(10))
  ).protocols(httpConfig)
}
