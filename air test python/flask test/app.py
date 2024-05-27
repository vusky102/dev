from flask import Flask, render_template, request,jsonify
import base64
import requests
import xmltodict
from lxml import etree

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/button_click', methods=['POST'])
def button_click():
    

    url = "https://apac.universal-api.pp.travelport.com/B2BGateway/connect/uAPI/AirService"
    authHeader = base64.b64encode(('Universal API/uAPI7426835859-9d6c0257' + ':' + 'i+5JA4r!m/').encode()).decode()
    headers = {
        'Content-Type': 'text/xml; charset=utf-8',
        'Accept': 'gzip,deflate',
        'Authorization': 'Basic ' + authHeader
    }

    
    # origin_code = "ICN"
    # destination_code = "HAN"
    # departure_date = "2023-12-29"

    airSearchtype = request.form.get('trip_type')
    origin_code = request.form.get('origin_code')
    destination_code = request.form.get('destination_code')
    departure_date = request.form.get('departure_date')
    arrival_date = request.form.get('arrival_date')
    

                # <com:SearchPassenger BookingTravelerRef="CNN01" Code="CNN" Age="8" />
                # <com:SearchPassenger BookingTravelerRef="INF01" Code="INF" Age="1" />

    if airSearchtype.lower() == "one_way":
        body = f"""
            <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
                <air:LowFareSearchReq AuthorizedBy="MODETOUREDEV" TraceId="2023020210102121" TargetBranch="P7200564" ReturnUpsellFare="false"  SolutionResult="true" xmlns:air="http://www.travelport.com/schema/air_v52_0" xmlns:com="http://www.travelport.com/schema/common_v52_0">
                <com:BillingPointOfSaleInfo OriginApplication="uAPI"/>
                    <air:SearchAirLeg>
                        <air:SearchOrigin>
                        <com:Airport Code="{origin_code}"/>
                        </air:SearchOrigin>
                        <air:SearchDestination>
                        <com:Airport Code="{destination_code}"/>
                        </air:SearchDestination>
                        <air:SearchDepTime PreferredTime="{departure_date}"/>
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
    else:
        body = f"""
            <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
                <air:LowFareSearchReq AuthorizedBy="MODETOUREDEV" TraceId="2023020210102121" TargetBranch="P7200564" ReturnUpsellFare="false"  SolutionResult="true" xmlns:air="http://www.travelport.com/schema/air_v52_0" xmlns:com="http://www.travelport.com/schema/common_v52_0">
                <com:BillingPointOfSaleInfo OriginApplication="uAPI"/>
                    <air:SearchAirLeg>
                        <air:SearchOrigin>
                        <com:Airport Code="{origin_code}"/>
                        </air:SearchOrigin>
                        <air:SearchDestination>
                        <com:Airport Code="{destination_code}"/>
                        </air:SearchDestination>
                        <air:SearchDepTime PreferredTime="{departure_date}"/>
                    </air:SearchAirLeg>
                    <air:SearchAirLeg>
                        <air:SearchOrigin>
                        <com:Airport Code="{destination_code}"/>
                        </air:SearchOrigin>
                        <air:SearchDestination>
                        <com:Airport Code="{origin_code}"/>
                        </air:SearchDestination>
                        <air:SearchDepTime PreferredTime="{arrival_date}"/>
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
                    <com:SearchPassenger BookingTravelerRef="ADT01" Code="ADT"/>
                
                    <air:AirPricingModifiers ETicketability="Required" FaresIndicator="AllFares">
                    </air:AirPricingModifiers>
                </air:LowFareSearchReq>
            </soap:Body>
            </soap:Envelope>
            """
        
        
        #     <air:ProhibitedCarriers><com:Carrier Code="HR"/> <com:Carrier Code="H1"/></air:ProhibitedCarriers>

    response = requests.post(url, headers=headers, data=body)
    result_xml = response.text

    # Parse the XML result using xmltodict
    #result_dict = xmltodict.parse(result_xml)

    
    xslt_file_path = r"C:\Users\Oxana&Lucas\Desktop\dev\air test python\LowFareSearchRsp.xslt"
    xslt_tree = etree.parse(xslt_file_path)
    transform = etree.XSLT(xslt_tree)

    
    transformed_result = transform(etree.XML(result_xml))

    

    return str(transformed_result)

if __name__ == '__main__':
    app.run(debug=True)
