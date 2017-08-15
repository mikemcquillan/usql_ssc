using Microsoft.Analytics.Interfaces;
using Microsoft.Analytics.Types.Sql;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace PostcodeLibrary
{
    public class PostcodeHelper
    {
        public static string PostcodePart1(string postcode)
        {
            return postcode.IndexOf(" ") == -1 ? postcode : postcode.Substring(0, postcode.IndexOf(" "));
        }

        public static string PostcodePart2(string postcode)
        {
            return postcode.IndexOf(" ") == -1 ? postcode : postcode.Substring(postcode.IndexOf(" ") + 1);
        }
    }
}