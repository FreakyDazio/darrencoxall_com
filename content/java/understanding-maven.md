---
date: 2015-10-05T09:00:00Z
title: Understanding Maven
type: post
---

With a recent change of jobs I am finding myself _re-learning_ java. The last time I used the language was in University and much of that was far from professional quality with regards to unit testing and software architecture. So with that in mind I am spending some time brushing up on the necessities one of which is dependency management.

It's easy enough to open up one of the high quality IDEs that are well known in the community such as Eclipse or IntelliJ, and get a dependency managed project running in no time. My problem with this is I like to know exactly what is happening, what has my IDE generated? and how can I achieve the same without ay IDE? So let's take a dive into Maven...

## What is Maven

Maven is one of the most popular dependency resolution and management tools in the Java community. What this means _(initially)_ to me is that it's a good choice for maintaining a set of external dependencies and ensuring our application is using specific versions that are known to work.

Installing maven is simple so I won't discuss that here, but you can find the official documentation [here][maven-install].

The key file is `pom.xml` (Project Object Model) which represents your project and dependencies in XML. Much like a `Gemfile` for Ruby or `package.json` for node. So looking at the [reference guide][pom] I'm going to create something very basic.

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                      http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.darrencoxall</groupId>
  <artifactId>learning-maven</artifactId>
  <version>1.0</version>
</project>
```

Here we need to ignore the `modelVersion` as 4 is the only acceptable version. The proceeding 3 attributes define the information about my own particular project.

With that defined I decided to see what happens when I run `mvn clean install`... The answer is lots to my surprise. I haven't even declared any dependencies yet. The output looks as though it has downloaded some maven related plugins so let's have a look at what they are.

- `maven-clean-plugin` removes build-time generated files
- `maven-resources-plugin` copies the relevant resource files to the output directory
- `maven-compiler-plugin` contains the compilation logic which is independent to the JDK used for maven
- `maven-surefire-plugin` generates a report of test results
- `maven-jar-plugin` which builds a JAR file

So these plugins are providing some of the basics but presumably maven can do a lot more via plugins as the core feature set is built as plugins.

We also have a new directory called "target". This is where our build artifacts are stored so this directory would presumably be ignored from any VCS.

## Using Maven

I'm now going to add a very simple application...

```java
// src/main/java/Application.java
package learningmaven;

class Application {
  public static void main(String[] arguments) {
    System.out.println("Hello, World!");
  }
}
```

Again running `mvn clean install` results in a few more things in the target directory. I'm not particularly bothered by them though as I should now have a working JAR file right?

    $ java -jar target/learning-maven-1.0.jar
    no main manifest attribute, in target/learning-maven-1.0.jar

So no, how is main set then? Well a bit of searching and I discovered the maven-jar-plugin can be configured to generate the relevant meta files for the jar. So my `pom.xml` will now look like the following: _key points are the addClasspath and mainClass_

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                      http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.darrencoxall</groupId>
  <artifactId>learning-maven</artifactId>
  <version>1.0</version>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        <version>2.4</version>
        <configuration>
          <archive>
            <manifest>
              <addClasspath>true</addClasspath>
              <mainClass>learningmaven.Application</mainClass>
            </manifest>
          </archive>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
```

Now let's just try this again...

    $ mvn clean install
    $ java -jar target/learning-maven-1.0.jar
    Hello, World!

Success! We have configured maven to build our project without any IDE. So now I want to use some dependencies and see how that works.

## Dependencies in Maven

I'm going to add [Joda-Time][joda] to my project as it's a well respected time library.

To do this I need to add the following into my POM.

```xml
<dependencies>
  <dependency>
    <groupId>joda-time</groupId>
    <artifactId>joda-time</artifactId>
    <version>2.8.2</version>
  </dependency>
</dependencies>
```

Fast-forward a bit and I also discovered that maven won't automatically make dependencies available to the classpath and so we need to automate this with another plugin, maven-dependency-plugin.

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-dependency-plugin</artifactId>
  <executions>
    <execution>
      <id>copy-dependencies</id>
      <phase>package</phase>
      <goals>
        <goal>copy-dependencies</goal>
      </goals>
      <configuration>
        <outputDirectory>${project.build.directory}</outputDirectory>
        <overWriteReleases>false</overWriteReleases>
        <overWriteSnapshots>true</overWriteSnapshots>
      </configuration>
    </execution>
  </executions>
</plugin>
```

With this in place dependencies are then available to our code and packaged into our jar. So let's use joda-time in our code.

```java
package learningmaven;

import org.joda.time.Instant;

class Application {
  public static void main(String[] arguments) {
    Instant now = Instant.now();
    System.out.println(now);
  }
}
```

Finally we can compile and build the project and see if it works.

    $ mvn clean install
    $ java -jar target/learning-maven-1.0.jar
    2015-10-03T20:41:27.516Z

Fantastic. So in this we have learnt a bit about how we can use maven to manage dependencies as well as bundle them into our applications. It can do a hell of a lot more but understanding the basics is important, it means I have a better understanding of maven outside of the interfaces available within an IDE.

It's so easy to become reliant on IDEs to create and work with Java projects but I want to make sure that the use of the tools doesn't obscure my understanding of the technologies. I want to be able to create small java applications from my terminal.

_Apologies if this is quite a simple task but being new/out-of-date to java means these simple subjects are often overlooked and shared learning is better than private learning._

[maven-install]: https://maven.apache.org/install.html
[pom]: https://maven.apache.org/pom.html
[joda]: http://www.joda.org/joda-time/
