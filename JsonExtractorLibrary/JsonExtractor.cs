using Microsoft.Analytics.Interfaces;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace JsonExtractorLibrary
{
    /// <summary>
    /// AtomicFileProcessing = true extractor for JSON, XML - file required in one hit
    /// False = extractor can deal with split or distributed files like CSV
    /// https://docs.microsoft.com/en-us/azure/data-lake-analytics/data-lake-analytics-u-sql-programmability-guide
    /// This call all be done via a script, see:
    /// https://www.sqlchick.com/entries/2017/9/4/querying-multi-structured-json-files-with-u-sql-in-azure-data-lake
    /// </summary>
    [SqlUserDefinedExtractor(AtomicFileProcessing = true)]
    public class JsonExtractor : IExtractor
    {
        // This is the only method exposed by the interface and must be implemented
        public override IEnumerable<IRow> Extract(IUnstructuredReader reader, IUpdatableRow row)
        {
            var jsonReader = new JsonTextReader(new StreamReader(reader.BaseStream));
            var serializer = new JsonSerializer();

            var pc = (JArray)serializer.Deserialize(jsonReader);
            var pcList = (List<PostcodeInfo>)pc.ToObject(typeof(List<PostcodeInfo>));

            foreach (PostcodeInfo pi in pcList)
            {
                row.Set<string>("Postcode", pi.Postcode);
                row.Set<string>("CountyCode", pi.CountyCode);
                row.Set<string>("DistrictCode", pi.DistrictCode);
                row.Set<string>("CountryCode", pi.CountryCode);
                row.Set<decimal?>("Latitude", (decimal?)pi.Latitude);
                row.Set<decimal?>("Longitude", (decimal?)pi.Longitude);

                yield return row.AsReadOnly();
            }
        }
    }

    public class PostcodeInfo
    {
        public string Postcode { get; set; }
        public string CountyCode { get; set; }
        public string DistrictCode { get; set; }
        public string CountryCode { get; set; }
        public float Latitude { get; set; }
        public float Longitude { get; set; }
    }
}