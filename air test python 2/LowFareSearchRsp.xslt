<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="fontSize">14px</xsl:param>
  <xsl:output method="html" indent="yes" omit-xml-declaration="yes" />

  <xsl:variable name="maximum">
    <xsl:value-of select="//*[local-name()='AirSegment' and not(preceding-sibling::node()/@Group > @Group or following-sibling::node()/@Group > @Group)]/@Group" />
  </xsl:variable>

  <xsl:template match="/">
    <html>
      <head>
        <title>Travelport Universal API Low Fare response</title>
        <style type="text/css">
          BODY, table {
            text-align: center;
            font-size: <xsl:value-of select="$fontSize" />
          }
          table.main {
            text-align: center;
            width: 100%;
            margin-bottom: 12px;
            border-bottom-style: solid;
            border-bottom-color: #0075b0;
          }
          table.main thead {
            text-align: center;
            background-color: #0075b0;
            color: white;
          }
          table.main caption {
            text-align: center;
            background-color: #0075b0;
            color: white;
            font-size: larger;
            font-weight: bold;
          }
          table.main td {
            text-align: center;
            padding: 1px;
          }
          tr.out td {
            border-top-style: solid;
            border-top-color: #72c7e7;
          }
          tr.in td {
            border-top-style: solid;
            border-top-color: #7ab800;
          }
          tr.middle td {
            text-align: center;
            border-top-style: solid;
            border-top-color: #dbceac;
          }
          td.time {
            text-align: center;
          }
          td.center {
            text-align: center;
          }
          h1 {
            text-align: center;
            background-color: #7ab800;
            color: white;
          }
        </style>
      </head>
      <body>
        <table>
          <tr>
            <td>
              <h1>
                <a name="#air">Air fares</a>
              </h1>
              <a href="#rail">Go to rail fares</a>
            </td>
          </tr>
          <xsl:apply-templates select="//*[local-name()='AirPricingSolution']"/>
          <xsl:apply-templates select="//*[local-name()='AirPricePoint']"/>
          <tr>
            <td>
              <h1>
                <a name="#rail">Rail fares</a>
              </h1>
              <a href="#air">Go to air fares</a>
            </td>
          </tr>
        </table>
        <xsl:apply-templates select="//*[local-name()='RailPricingSolution']"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="//*[local-name()='AirPricingSolution']">
    <xsl:variable name="Amt">
      <xsl:value-of select="./@TotalPrice"/>
    </xsl:variable>
    <tr>
      <td>
        <table class="main">
          <caption>
            Total price:
            <xsl:value-of select="$Amt"/>
          </caption>
          <thead >
            <tr>
              <th>Direction</th>
              <th>Date</th>
              <th>Flight</th>
              <th>Depart</th>
              <th>Arrive</th>
              <th>From</th>
              <th>To</th>
              <th>Class</th>
              <th>Cabin</th>
              <th>Source</th>
            </tr>
          </thead>
          <tbody>
            <xsl:apply-templates select="*[local-name()='AirSegmentRef']" />
            <xsl:apply-templates select="*[local-name()='Journey']" />
          </tbody>
        </table>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="//*[local-name()='AirPricePoint']">
    <xsl:variable name="Amt">
      <xsl:value-of select="./@TotalPrice"/>
    </xsl:variable>
    <tr>
      <td>
        <table class="main">
          <caption>
            
            <xsl:value-of select="./@TotalPrice"/> (base: <xsl:value-of select="./@BasePrice"/> - taxes: <xsl:value-of select="./@Taxes"/>)
          </caption>
          <thead >
            <tr>
              <th>Direction</th>
              <th>Date</th>
              <th>Flight</th>
              <th>Depart</th>
              <th>Arrive</th>
              <th>From</th>
              <th>To</th>
              <th>Class</th>
              <th>Cabin</th>
              <th>Source</th>
              <th>Brand</th>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="*[local-name()='AirPricingInfo'][position()=1]">
              <xsl:apply-templates select="*[local-name()='FlightOptionsList']/*[local-name()='FlightOption']/*[local-name()='Option']" />
            </xsl:for-each>
          </tbody>
        </table>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="*[local-name()='AirSegmentRef']">
    <xsl:variable name="indexFlight" select="./@Key"/>
    <xsl:variable name="position" select="position()-2" />

    <xsl:variable name="connecting" select="../*[local-name()='Connection' and @SegmentIndex=$position]/@SegmentIndex" />

    <xsl:variable name="bookingClass" select="../*[local-name()='AirPricingInfo'][position()=1]/*[local-name()='BookingInfo' and @SegmentRef=$indexFlight]/@BookingCode"/>
    <xsl:variable name="cabinClass" select="../*[local-name()='AirPricingInfo'][position()=1]/*[local-name()='BookingInfo' and @SegmentRef=$indexFlight]/@CabinClass"/>
    <xsl:variable name="providerCode" select="../*[local-name()='AirPricingInfo'][position()=1]/@ProviderCode"/>

    <xsl:for-each select="//*[local-name()='AirSegment' and ./@Key=$indexFlight]">
      <xsl:variable name="directionName">
        <xsl:if test="not($connecting)" >
          <xsl:if test="$maximum>1">
            OD Part <xsl:value-of select="./@Group"/>
          </xsl:if>
          <xsl:if test="$maximum=1">
            <xsl:choose>
              <xsl:when test="./@Group='0'">Outbound</xsl:when>
              <xsl:otherwise>Inbound</xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <xsl:if test="$maximum=0">Oneway</xsl:if>
        </xsl:if>
      </xsl:variable>
      <tr>
        <xsl:attribute name="class">
          <xsl:choose>
            <xsl:when test="./@Group='0' and $directionName!=''">out</xsl:when>
            <xsl:when test="($maximum=./@Group and $directionName!='')">in</xsl:when>
            <xsl:when test="$directionName=''"></xsl:when>
            <xsl:otherwise >middle</xsl:otherwise >
          </xsl:choose>
        </xsl:attribute>
        <td >
          <xsl:value-of select="$directionName"/>
        </td>
        <td>
          <xsl:value-of select="substring(./@DepartureTime,1,10)"/>
        </td>
        <td>
          <xsl:value-of select="./@Carrier"/>
          <xsl:value-of select="./@FlightNumber"/>
        </td>
        <td class="time">
          <xsl:value-of select="substring(./@DepartureTime,12,5)"/>
        </td>
        <td class="time">
          <xsl:value-of select="substring(./@ArrivalTime,12,5)"/>
        </td>
        <td>
          <xsl:value-of select="./@Origin"/>
        </td>
        <td>
          <xsl:value-of select="./@Destination"/>
        </td>
        <td class="center">
          <xsl:value-of select="$bookingClass"/>
        </td>
        <td>
          <xsl:choose >
            <xsl:when test="$cabinClass">
              <xsl:value-of select="$cabinClass"/>
            </xsl:when>
            <xsl:otherwise>
              &#160;
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:value-of select="$providerCode"/>
          <xsl:if test="./@AvailabilitySource">
            -
            <xsl:value-of select="./@AvailabilitySource"/>
          </xsl:if>
        </td>
      </tr>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*[local-name()='Journey']">
    <xsl:call-template name="SegmentsForJourney" />
  </xsl:template>

  <xsl:template name="SegmentsForJourney">
    <xsl:for-each select="*[local-name()='AirSegmentRef']">
      <xsl:variable name="indexFlight" select="./@Key"/>
      <xsl:variable name="position" select="position()-2" />

      <xsl:variable name="connecting" select="../../*[local-name()='Connection' and @SegmentIndex=$position]/@SegmentIndex" />

      <xsl:variable name="bookingClass" select="../../*[local-name()='AirPricingInfo'][position()=1]/*[local-name()='BookingInfo' and @SegmentRef=$indexFlight]/@BookingCode"/>
      <xsl:variable name="cabinClass" select="../../*[local-name()='AirPricingInfo'][position()=1]/*[local-name()='BookingInfo' and @SegmentRef=$indexFlight]/@CabinClass"/>
      <xsl:variable name="providerCode" select="../../*[local-name()='AirPricingInfo'][position()=1]/@ProviderCode"/>

      <xsl:for-each select="//*[local-name()='AirSegment' and ./@Key=$indexFlight]">
        <xsl:variable name="directionName">
          <xsl:if test="not($connecting)" >
            <xsl:if test="$maximum>1">
              OD Part <xsl:value-of select="./@Group"/>
            </xsl:if>
            <xsl:if test="$maximum=1">
              <xsl:choose>
                <xsl:when test="./@Group='0'">Outbound</xsl:when>
                <xsl:otherwise>Inbound</xsl:otherwise>
              </xsl:choose>
            </xsl:if>
            <xsl:if test="$maximum=0">Oneway</xsl:if>
          </xsl:if>
        </xsl:variable>
        <tr>
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="./@Group='0' and $directionName!=''">out</xsl:when>
              <xsl:when test="($maximum=./@Group and $directionName!='')">in</xsl:when>
              <xsl:when test="$directionName=''"></xsl:when>
              <xsl:otherwise >middle</xsl:otherwise >
            </xsl:choose>
          </xsl:attribute>
          <td >
            <xsl:value-of select="$directionName"/>
          </td>
          <td>
            <xsl:value-of select="substring(./@DepartureTime,1,10)"/>
          </td>
          <td>
            <xsl:value-of select="./@Carrier"/>
            <xsl:value-of select="./@FlightNumber"/>
          </td>
          <td class="time">
            <xsl:value-of select="substring(./@DepartureTime,12,5)"/>
          </td>
          <td class="time">
            <xsl:value-of select="substring(./@ArrivalTime,12,5)"/>
          </td>
          <td>
            <xsl:value-of select="./@Origin"/>
          </td>
          <td>
            <xsl:value-of select="./@Destination"/>
          </td>
          <td class="center">
            <xsl:value-of select="$bookingClass"/>
          </td>
          <td>
            <xsl:choose >
              <xsl:when test="$cabinClass">
                <xsl:value-of select="$cabinClass"/>
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td>
            <xsl:value-of select="$providerCode"/>
            <xsl:if test="./@AvailabilitySource">
              -
              <xsl:value-of select="./@AvailabilitySource"/>
            </xsl:if>
          </td>
        </tr>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*[local-name()='FlightOptionsList']/*[local-name()='FlightOption']/*[local-name()='Option']">
    <xsl:for-each select="*[local-name()='BookingInfo']">
      <xsl:variable name="indexFlight" select="./@SegmentRef"/>
      <xsl:variable name="position" select="position()-2" />

      <xsl:variable name="connecting" select="../*[local-name()='Connection' and @SegmentIndex=$position]/@SegmentIndex" />

      <xsl:variable name="providerCode" select="ancestor::*[local-name() = 'AirPricingInfo']/@ProviderCode" />

      <xsl:variable name="bookingClass" select="./@BookingCode"/>
      <xsl:variable name="cabinClass" select="./@CabinClass"/>
      <xsl:variable name="fareInfoRef" select="./@FareInfoRef"/>

      <xsl:variable name="brandId" select="/*[local-name()='FareInfo' and @Key=$fareInfoRef]/*[local-name()='Brand']/@BrandId" />
      <xsl:variable name="brandName" select="//*[local-name()='Brand' and @Key=$brandId]/@Name"/>
      
      
      <xsl:for-each select="//*[local-name()='AirSegment' and ./@Key=$indexFlight]">
        <xsl:variable name="directionName">
          <xsl:if test="not($connecting)" >
            <xsl:if test="$maximum>1">
              OD Part <xsl:value-of select="./@Group"/>
            </xsl:if>
            <xsl:if test="$maximum=1">
              <xsl:choose>
                <xsl:when test="./@Group='0'">Outbound</xsl:when>
                <xsl:otherwise>Inbound</xsl:otherwise>
              </xsl:choose>
            </xsl:if>
            <xsl:if test="$maximum=0">Oneway</xsl:if>
          </xsl:if>
        </xsl:variable>
        <tr>
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="./@Group='0' and $directionName!=''">out</xsl:when>
              <xsl:when test="($maximum=./@Group and $directionName!='')">in</xsl:when>
              <xsl:when test="$directionName=''"></xsl:when>
              <xsl:otherwise >middle</xsl:otherwise >
            </xsl:choose>
          </xsl:attribute>
          <td >
            <xsl:value-of select="$directionName"/>
          </td>
          <td>
            <xsl:value-of select="substring(./@DepartureTime,1,10)"/>
          </td>
          <td>
            <xsl:value-of select="./@Carrier"/>
            <xsl:value-of select="./@FlightNumber"/>
          </td>
          <td class="time">
            <xsl:value-of select="substring(./@DepartureTime,12,5)"/>
          </td>
          <td class="time">
            <xsl:value-of select="substring(./@ArrivalTime,12,5)"/>
          </td>
          <td>
            <xsl:value-of select="./@Origin"/>
          </td>
          <td>
            <xsl:value-of select="./@Destination"/>
          </td>
          <td class="center">
            <xsl:value-of select="$bookingClass"/>
          </td>
          <td >
            <xsl:choose >
              <xsl:when test="$cabinClass">
                <xsl:value-of select="$cabinClass"/>
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td>
            <xsl:value-of select="$providerCode"/>
            <xsl:if test="./@AvailabilitySource">
              -
              <xsl:value-of select="./@AvailabilitySource"/>
            </xsl:if>
          </td>
          <td>
            <xsl:value-of select="$brandName"/>
          </td>

        </tr>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="//*[local-name()='RailPricingSolution']">
    <xsl:variable name="Amt">
      <xsl:value-of select="./@TotalPrice"/>
    </xsl:variable>
    <xsl:variable name="Supplier">
      <xsl:value-of select="./@SupplierCode"/>
    </xsl:variable>
    <tr>
      <td>
        <table class="main">
          <caption>
            From <xsl:value-of select="$Supplier"/> - Total price:
            <xsl:value-of select="$Amt"/>
          </caption>
          <thead >
            <tr>
              <th>Direction</th>
              <th>Date</th>
              <th>Train</th>
              <th>Depart</th>
              <th>Arrive</th>
              <th>From</th>
              <th>To</th>
            </tr>
          </thead>
          <tbody>
            <xsl:apply-templates select="*[local-name()='RailJourneyRef']" />
          </tbody>
        </table>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="*[local-name()='RailJourneyRef']">
    <xsl:variable name="indexJourney" select="./@Key"/>
    <xsl:for-each select="//*[local-name()='RailJourney' and ./@Key=$indexJourney]">
      <xsl:variable name="direction" select="./@JourneyDirection"/>
      <xsl:apply-templates select="*[local-name()='RailSegmentRef']">
        <xsl:with-param name="direction" select="$direction"></xsl:with-param>
      </xsl:apply-templates>
    </xsl:for-each>

  </xsl:template>

  <xsl:template match="*[local-name()='RailSegmentRef']">
    <xsl:param name="direction"/>

    <xsl:variable name="position" select="position()" />
    <xsl:variable name="directionHeader">
      <xsl:choose>
        <xsl:when test="position()=1">
          <xsl:value-of select="$direction"/>
        </xsl:when>
        <xsl:otherwise>

        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="indexSegment" select="./@Key"/>
    <xsl:for-each select="//*[local-name()='RailSegment' and ./@Key=$indexSegment]">
      <tr>
        <xsl:attribute name="class">
          <xsl:choose>
            <xsl:when test="$directionHeader='Outward'">out</xsl:when>
            <xsl:when test="$directionHeader='Return'">in</xsl:when>
            <xsl:otherwise ></xsl:otherwise >
          </xsl:choose>
        </xsl:attribute>
        <td>
          <xsl:value-of select="$directionHeader"/>
        </td>
        <td>
          <xsl:value-of select="substring(./@DepartureTime,1,10)"/>
        </td>
        <td>
          <xsl:value-of select="./@TrainNumber"/>
        </td>
        <td class="time">
          <xsl:value-of select="substring(./@DepartureTime,12,5)"/>
        </td>
        <td class="time">
          <xsl:value-of select="substring(./@ArrivalTime,12,5)"/>
        </td>
        <td>
          <xsl:value-of select="./@OriginStationName"/>
        </td>
        <td>
          <xsl:value-of select="./@DestinationStationName"/>
        </td>
      </tr>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
