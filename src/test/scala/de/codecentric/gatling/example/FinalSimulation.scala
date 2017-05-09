package de.codecentric.gatling.example

import io.gatling.core.Predef._
import io.gatling.core.scenario.Simulation
import io.gatling.http.Predef._

/**
  * Created by ronny on 08.05.17.
  */
class FinalSimulation extends Simulation {

  private val httpConfig = http.baseURL("http://computer-database.gatling.io")

  private val numberUsers = 10

  private val numberFeeder = for (x <- 0 until numberUsers) yield Map("veryImportantId" -> x)

  private val openMainPage = exec(http("open").
    get("/")).
    pause(1)

  private val addComputer = feed(numberFeeder.iterator).
    exec(http("create new computer").
      post("/computers").
      formParamMap(Map("name" -> "Codecentric Machine ${veryImportantId}"))
    )

  private val checkComputer = feed(numberFeeder.iterator).
    exec(http("request computer").
      get("/computers?f=Codecentric Machine ${veryImportantId}").
      check(css("a:contains('Codecentric Machine ${veryImportantId}')", "href"))
    )

  setUp(scenario("combined").
    exec(openMainPage).pause(1).exec(addComputer).pause(1).exec(checkComputer).
    inject(atOnceUsers(numberUsers))
  ).protocols(httpConfig)
}
