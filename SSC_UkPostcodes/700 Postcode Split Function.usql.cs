using Microsoft.Analytics.Interfaces;
using Microsoft.Analytics.Types.Sql;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace SSC_UkPostcodes
{
    public static class FunctionTests
    {
        public static string PostcodePart(string postcode, bool part1)
        {
            string pcode = null;

            if (part1)
            {
                pcode = postcode.IndexOf(" ") == -1 ? postcode : postcode.Substring(0, postcode.IndexOf(" "));
            }
            else
            {
                pcode = postcode.IndexOf(" ") == -1 ? postcode : postcode.Substring(postcode.IndexOf(" ") + 1);
            }

            return pcode;
        }
    }
}
