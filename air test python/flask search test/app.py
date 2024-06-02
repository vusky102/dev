from flask import Flask, render_template, request, jsonify
import base64
import requests
import xmltodict
from lxml import etree
from datetime import datetime, timedelta

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/button_click', methods=['POST'])
def button_click():
    # Set your URL and authentication headers
    url = "https://apac.universal-api.pp.travelport.com/B2BGateway/connect/uAPI/AirService"
    authHeader = base64.b64encode(('............').encode()).decode()
    headers = {
        'Content-Type': 'text/xml; charset=utf-8',
        'Accept': 'gzip,deflate',
        'Authorization': 'Basic ' + authHeader
    }

    # Get parameters from the HTML form
    origin_code = request.args.get('origin')
    destination_code = request.args.get('destination')
    departure_date = request.args.get('departure_date')

    # Convert departure date to datetime object
    departure_date1 = datetime.strptime(departure_date, '%Y-%m-%d')

    # Define the range of dates, +/- 7 days from the selected date
    date_range = [departure_date1 + timedelta(days=i) for i in range(-7, 8)]

    # Dictionary to store results for each date
    results = {}

    # Perform SOAP requests for each date and get the lowest prices
    for date in date_range:
        # Modify the SOAP request body for each date
        body = f"""
            <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
                <air:LowFareSearchReq AuthorizedBy="MODETOUREDEV" TraceId="" TargetBranch="" ReturnUpsellFare="false"  SolutionResult="true" xmlns:air="http://www.travelport.com/schema/air_v52_0" xmlns:com="http://www.travelport.com/schema/common_v52_0">
                <com:BillingPointOfSaleInfo OriginApplication="uAPI"/>
                    <air:SearchAirLeg>
                        <air:SearchOrigin>
                        <com:Airport Code="{origin_code}"/>
                        </air:SearchOrigin>
                        <air:SearchDestination>
                        <com:Airport Code="{destination_code}"/>
                        </air:SearchDestination>
                        <air:SearchDepTime PreferredTime="{date.strftime('%Y-%m-%d')}"/>
                    </air:SearchAirLeg>
                    <air:AirSearchModifiers>
                        <air:PreferredProviders>
                        <com:Provider Code="1G"/>
                        </air:PreferredProviders>
                        <air:ProhibitedCarriers>
                            <com:Carrier Code="HR"/>
                            <com:Carrier Code="H1"/>
                            <com:Carrier Code="A1"/>
                            <com:Carrier Code="W2"/>
                        </air:ProhibitedCarriers>
                        <air:FlightType DoubleInterlineCon="false" DoubleOnlineCon="false" SingleInterlineCon="false" SingleOnlineCon="false" StopDirects="true" NonStopDirects="true"/>
                    </air:AirSearchModifiers>
                    <com:SearchPassenger xmlns="http://www.travelport.com/schema/common_v52_0" Code="ADT" />
                    <air:AirPricingModifiers ETicketability="Required" FaresIndicator="AllFares">
                    </air:AirPricingModifiers>
                </air:LowFareSearchReq>
            </soap:Body>
            </soap:Envelope>
            """

        # Make the SOAP request
        response = requests.post(url, headers=headers, data=body)
        result_xml = response.text
        result = xmltodict.parse(result_xml)

        # Store the result in the dictionary
        results[date.strftime('%Y-%m-%d')] = result['SOAP:Envelope']['SOAP:Body']['air:LowFareSearchRsp']['air:AirPricingSolution'][0]['@TotalPrice']

    # Return the results as JSON
    return jsonify(results)


if __name__ == '__main__':
    app.run(debug=True)
